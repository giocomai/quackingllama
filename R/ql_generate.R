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
                        host = NULL,
                        model = NULL,
                        temperature = NULL,
                        seed = NULL) {
  options_l <- ql_get_options(
    system = system,
    host = host,
    model = model,
    temperature = temperature,
    seed = seed
  )

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
    dplyr::mutate(
      prompt = prompt,
      system = options_l[["system"]],
      seed = options_l[["seed"]],
      temperature = options_l[["temperature"]]
    ) |>
    dplyr::relocate(response, prompt)

  output_df
}
