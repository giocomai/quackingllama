#' Generate a response and return the result in a data frame
#'
#' @inheritParams ql_hash
#'
#' @return A data frame, including a response column, as well as other information returned by the model.
#' @export
#'
#' @examples
#' ql_prompt("a haiku") |>
#'   ql_generate()
ql_generate <- function(prompt_df) {
  current_hash <- ql_hash(prompt_df)

  if (ql_get_db_options(options = "db")[[1]]) {
    ## check for local database
    duckdb_file <- fs::path(
      ql_get_db_options(options = "db_folder")[[1]],
      fs::path_ext_set(ql_get_db_options(options = "db_name")[[1]], "duckdb")
    )

    if (!fs::file_exists(duckdb_file)) {
      table_exists <- FALSE
    } else {
      con <- duckdb::dbConnect(duckdb::duckdb(),
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
          dplyr::filter(current_hash %in% hash) |>
          dplyr::collect()

        duckdb::dbDisconnect(conn = con)

        if (nrow(cached_df) > 0) {
          return(cached_df)
        }
      }
    }
  }

  req <- ql_request(
    prompt_df = prompt_df,
    endpoint = "generate"
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
    dplyr::mutate(dplyr::across(dplyr::where(is.integer), as.numeric)) |>
    dplyr::bind_cols(prompt_df |>
      dplyr::select(-model)) |>
    dplyr::relocate(response, prompt) |>
    dplyr::mutate(hash = current_hash)

  if (ql_get_db_options(options = "db")[[1]]) {
    con <- duckdb::dbConnect(duckdb::duckdb(),
      dbdir = duckdb_file,
      read_only = FALSE
    )

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
    }

    duckdb::dbDisconnect(conn = con)
  }

  output_df
}
