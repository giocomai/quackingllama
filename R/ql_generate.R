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
#' ql_generate("a haiku", seed = 1)
ql_generate <- function(prompt,
                        system = NULL,
                        host = NULL,
                        model = NULL,
                        temperature = NULL,
                        seed = NULL,
                        endpoint = "api/generate") {
  options_l <- ql_get_options(
    system = system,
    host = host,
    model = model,
    temperature = temperature,
    seed = seed
  )

  req <- httr2::request(options_l[["host"]]) |>
    httr2::req_url_path(endpoint) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(
      list(
        model = options_l[["model"]],
        prompt = prompt,
        stream = FALSE,
        raw = FALSE,
        options = list(
          seed = options_l[["seed"]],
          temperature = options_l[["temperature"]]
        ),
        system = options_l[["system"]]
      )
    ) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- req |>
    httr2::req_perform()

  resp_l <- resp |>
    httr2::resp_body_json()

  resp_l[["context"]] <- NULL

  output_df <- resp_l |>
    tibble::as_tibble() |>
    dplyr::mutate(
      prompt = prompt,
      system = options_l[["system"]],
      seed = options_l[["seed"]],
      temperature = options_l[["temperature"]]
    ) |>
    dplyr::relocate(response, prompt)

  output_df
}
