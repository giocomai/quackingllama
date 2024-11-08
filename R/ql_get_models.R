#' Get available models
#'
#' @param host Defaults to "http://localhost:11434", where locally deployed
#'   Ollama usually responds.
#'
#' @return A data frame (a tibble) with details on all locally available models.
#' @export
#'
#' @examples
#' \dontrun{
#' ql_get_models()
#' }
ql_get_models <- function(host = "http://localhost:11434") {
  req <- httr2::request(host) |>
    httr2::req_url_path("/api/tags") |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- req |>
    httr2::req_perform()

  resp_l <- resp |>
    httr2::resp_body_json()

  models_df <- resp_l |>
    purrr::pluck("models") |>
    purrr::map(
      .f = \(current_model) {
        current_model |>
          purrr::list_flatten() |>
          tibble::as_tibble()
      }
    ) |>
    purrr::list_rbind()

  models_df
}
