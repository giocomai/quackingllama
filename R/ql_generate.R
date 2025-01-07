#' Generate a response and return the result in a data frame
#'
#' @param prompt A prompt for the LLM.
#' @inheritParams ql_set_options
#'
#' @return A data frame, including a response column, as well as other information returned by the model.
#' @export
#'
#' @examples
#'
#' ql_generate("a haiku")
ql_generate <- function(prompt,
                        system = NULL,
                        format = NULL,
                        model = NULL,
                        temperature = NULL,
                        seed = NULL,
                        host = NULL) {
  options_l <- ql_get_options(
    system = system,
    host = host,
    model = model,
    temperature = temperature,
    seed = seed
  )

  if (is.null(format)) {
    format_string <- ""
  } else {
    format_string <- yyjsonr::write_json_str(format)
  }

  input_df <- tibble::tibble(
    prompt = prompt,
    system = options_l[["system"]],
    seed = options_l[["seed"]],
    temperature = as.numeric(options_l[["temperature"]]),
    model = as.character(options_l[["model"]]),
    format = as.character(format_string)
  )

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
        db_tbl <- dplyr::tbl(src = con, "generate") |>
          dplyr::inner_join(
            y = input_df |>
              dplyr::select(-temperature, -seed),
            by = c(
              "prompt",
              "system",
              "format",
              "model"
            ),
            copy = TRUE
          )

        db_tbl_nrow <- db_tbl |>
          dplyr::count() |>
          dplyr::pull(n)

        if (db_tbl_nrow == 0) {
          tbl_row_number <- db_tbl_nrow

          duckdb::dbDisconnect(conn = con)
        } else if (options_l[["temperature"]] == 0) {
          db_tbl_temperature_filtered <- db_tbl |>
            dplyr::filter(temperature == 0)

          temperature_row_number <- db_tbl_temperature_filtered |>
            dplyr::summarise(row_number = dplyr::n()) |>
            dplyr::pull(row_number)

          if (temperature_row_number >= length(prompt)) {
            output_df <- db_tbl_temperature_filtered |>
              dplyr::distinct(prompt, system, format, model, .keep_all = TRUE) |>
              dplyr::collect()

            duckdb::dbDisconnect(conn = con)

            return(output_df)
          } else {
            duckdb::dbDisconnect(conn = con)
          }
        } else {
          db_tbl_filtered <- db_tbl |>
            dplyr::inner_join(
              y = input_df |>
                dplyr::select(seed, temperature),
              by = c("seed", "temperature"),
              copy = TRUE
            )

          tbl_row_number <- db_tbl_filtered |>
            dplyr::summarise(row_number = dplyr::n()) |>
            dplyr::pull(row_number)

          if (tbl_row_number >= length(prompt)) {
            output_df <- db_tbl_filtered |>
              dplyr::distinct(prompt, system, format, model, .keep_all = TRUE) |>
              dplyr::collect()

            duckdb::dbDisconnect(conn = con)

            return(output_df)
          } else {
            duckdb::dbDisconnect(conn = con)
          }
        }
      }
    }
  }

  req <- ql_request(
    prompt = prompt,
    system = system,
    format = format,
    host = host,
    model = model,
    temperature = temperature,
    seed = seed,
    endpoint = "generate"
  )

  resp <- req |>
    httr2::req_perform()

  resp_l <- resp |>
    httr2::resp_body_json()

  resp_l[["context"]] <- NULL

  output_df <- resp_l |>
    tibble::as_tibble() |>
    dplyr::mutate(dplyr::across(dplyr::where(is.integer), as.numeric)) |>
    dplyr::bind_cols(input_df |>
      dplyr::select(-model)) |>
    dplyr::relocate(response, prompt)

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
