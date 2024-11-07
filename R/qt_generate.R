#' Generate a response and return the result in a data frame
#'
#' @param prompt
#' @param system
#' @param host
#' @param model
#' @param endpoint
#' @param temperature
#' @param seed
#'
#' @return
#' @export
#'
#' @examples
ql_generate <- function(prompt,
                        system = "You are a helpful assistant.",
                        host = "http://localhost:11434",
                        model = "llama3.2",
                        endpoint = "api/generate",
                        temperature = 0,
                        seed = NULL) {

  if (is.null(seed)) {
    seed <- sample.int(n = .Machine$integer.max, size = 1)
  }

  req <- httr2::request(host) |>
    httr2::req_url_path(endpoint) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(
      list(
        model = model,
        prompt = prompt,
        stream = FALSE,
        raw = FALSE,
        options = list(seed = seed,
                       temperature = temperature),
        system = system
      )
    ) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- req |>
    httr2::req_perform()

  resp_l <- resp |>
    httr2::resp_body_json()

  output_df <- tibble::tibble(
    doc_id = 1,
    response = resp_l |>
      purrr::pluck("response"),
    model = resp_l |>
      purrr::pluck("model"),
    prompt = prompt,
    system = system,
    seed = seed,
    temperature = temperature,
    prompt_eval_count = resp_l |>
      purrr::pluck("prompt_eval_count"),
    eval_count = resp_l |>
      purrr::pluck("eval_count"),
    total_duration = resp_l |>
      purrr::pluck("total_duration"),
    load_duration = resp_l |>
      purrr::pluck("load_duration"),
    eval_duration = resp_l |>
      purrr::pluck("eval_duration"),
    done = resp_l |>
      purrr::pluck("done"),
    done_reason = resp_l |>
      purrr::pluck("done_reason"),
    created_at = resp_l |>
      purrr::pluck("created_at")
  )

  output_df
}
