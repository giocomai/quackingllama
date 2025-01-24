#' Generate a data frame with all relevant inputs for the LLM.
#'
#' Typically passed to {ql_generate()}.
#'
#' For more details and context about each parameter, see \url{https://github.com/ollama/ollama/blob/main/docs/api.md}.
#'
#' @param prompt A prompt for the LLM.
#' @inheritParams ql_set_options
#'
#' @returns
#' @export
#'
#' @examples
ql_prompt <- function(prompt,
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

  if (as.numeric(options_l[["temperature"]]) == 0) {
    # if temperature is set to zero, seed is inconsequential
    seed <- 0
  } else {
    seed <- options_l[["seed"]]
  }

  prompt_df <- tibble::tibble(
    prompt = prompt,
    system = options_l[["system"]],
    seed = seed,
    temperature = as.numeric(options_l[["temperature"]]),
    model = as.character(options_l[["model"]]),
    format = as.character(format_string)
  )

  prompt_df
}
