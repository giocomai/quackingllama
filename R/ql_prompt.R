#' Generate a data frame with all relevant inputs for the LLM.
#'
#' Typically passed to {ql_generate()}.
#'
#' For more details and context about each parameter, see
#' \url{https://github.com/ollama/ollama/blob/main/docs/api.md}.
#'
#' @param prompt A prompt for the LLM.
#' @param hash Defaults to TRUE. If TRUE, adds a column with the hash of all
#'   other components of the prompt. Used internally for caching. Can be added
#'   separately with {ql_hash()}.
#' @inheritParams ql_set_options
#'
#' @returns A tibble with all main components of a query, to be passed to
#'   {ql_generate()}.
#' @export
#'
#' @examples
#' ql_prompt("a haiku")
ql_prompt <- function(prompt,
                      system = NULL,
                      format = NULL,
                      model = NULL,
                      temperature = NULL,
                      seed = NULL,
                      host = NULL,
                      hash = TRUE) {
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

  if (hash) {
    prompt_df <- ql_hash(prompt_df = prompt_df)
  }
  prompt_df
}
