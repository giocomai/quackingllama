#' Generate a response and return the result in a data frame
#'
#' @param only_cached Defaults to FALSE. If TRUE, only cached responses are
#'   returned.
#' @inheritParams ql_hash
#' @inheritParams ql_request
#'
#' @return A data frame, including a response column, as well as other
#'   information returned by the model.
#' @export
#'
#' @examples
#' ql_prompt("a haiku") |>
#'   ql_generate()
ql_generate <- function(prompt_df,
                        only_cached = FALSE,
                        host = NULL,
                        message = NULL,
                        timeout = NULL) {
  model <- unique(prompt_df[["model"]])

  if (length(model) > 1) {
    cli::cli_abort(
      message = c(
        x = "{.fun ql_generate} accepts only prompts with one model.",
        i = "The current prompt includes the following models:
        {stringr::str_flatten_comma(sQuote(model))}"
      )
    )
  }

  prompt_df <- ql_hash(prompt_df)

  prompt_to_process_df <- prompt_df |>
    dplyr::distinct()

  db_options_l <- ql_get_db_options()

  if (db_options_l[["db"]]) {
    if (db_options_l[["db_filename"]] == "") {
      db_filename <- stringr::str_c(c("quackingllama", model),
        collapse = "-"
      ) |>
        stringr::str_replace_all(
          pattern = "[[:punct:]]",
          replacement = "_"
        ) |>
        fs::path_sanitize()
    } else {
      db_filename <- db_options_l[["db_filename"]]
    }

    duckdb_file <- fs::path(
      db_options_l[["db_folder"]],
      fs::path_ext_set(db_filename, "duckdb")
    )

    if (!fs::file_exists(duckdb_file)) {
      table_exists <- FALSE
    } else {
      con <- duckdb::dbConnect(
        duckdb::duckdb(),
        dbdir = duckdb_file,
        read_only = TRUE
      )

      table_exists <- duckdb::dbExistsTable(
        conn = con,
        name = "generate"
      )

      if (!table_exists) {
        duckdb::dbDisconnect(conn = con)
      } else {
        cached_df <- dplyr::tbl(src = con, "generate") |>
          dplyr::filter(.data[["hash"]] %in% prompt_df$hash) |>
          dplyr::collect()

        duckdb::dbDisconnect(conn = con)

        cached_df <- prompt_df |>
          dplyr::select("hash") |>
          dplyr::left_join(
            y = cached_df,
            by = "hash"
          ) |>
          dplyr::relocate(
            "hash",
            .after = dplyr::last_col()
          ) |>
          dplyr::filter(!is.na(model))

        if (only_cached) {
          return(cached_df)
        }

        prompt_to_process_df <- prompt_df |>
          dplyr::anti_join(
            y = cached_df,
            by = "hash"
          ) |>
          dplyr::distinct()
      }
    }
  }

  if (nrow(prompt_to_process_df) == nrow(prompt_df)) {
    cached_df <- NULL
  }

  if (db_options_l[["db"]]) {
    con <- duckdb::dbConnect(
      duckdb::duckdb(),
      dbdir = duckdb_file,
      read_only = FALSE
    )
  }

  new_df <- purrr::map(
    .progress = model,
    .x = purrr::transpose(prompt_to_process_df),
    .f = \(current_prompt) {
      req <- ql_request(
        prompt_df = current_prompt,
        endpoint = "generate",
        host = host,
        message = message,
        timeout = timeout
      )

      resp <- req |>
        httr2::req_perform()

      resp_l <- resp |>
        httr2::resp_body_json()

      if (!is.null(resp_l[["error"]])) {
        rlang::abort(message = resp_l[["error"]])
      }

      resp_l[["context"]] <- NULL

      output_df <- resp_l |>
        tibble::as_tibble() |>
        dplyr::mutate(timeout = db_options_l[["timeout"]]) |>
        dplyr::mutate(dplyr::across(dplyr::where(is.integer), as.numeric)) |>
        dplyr::bind_cols(
          tibble::as_tibble(current_prompt) |>
            dplyr::select(-"model")
        ) |>
        dplyr::relocate("response", "prompt") |>
        dplyr::relocate("model", "system", "format", "seed", "temperature",
          .after = "model"
        )

      if (db_options_l[["db"]]) {
        if (table_exists) {
          duckdb::dbAppendTable(
            conn = con,
            name = "generate",
            value = output_df
          )
        } else {
          duckdb::dbWriteTable(
            conn = con,
            name = "generate",
            value = output_df
          )
          table_exists <<- duckdb::dbExistsTable(
            conn = con,
            name = "generate"
          )
        }
      }
      output_df
    }
  ) |>
    purrr::list_rbind()

  if (db_options_l[["db"]]) {
    duckdb::dbDisconnect(conn = con)
  }

  if (is.null(cached_df)) {
    return(new_df)
  } else {
    prompt_df |>
      dplyr::select("hash") |>
      dplyr::left_join(
        y = dplyr::bind_rows(
          cached_df,
          new_df
        ),
        by = "hash"
      ) |>
      dplyr::relocate(
        "hash",
        .after = dplyr::last_col()
      )
  }
}
