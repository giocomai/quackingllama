#' Set Ollama API keys typically used for cloud models
#'
#' @param api_keys Valid Ollama API keys, typically used for cloud models.
#'
#' @returns Invisibly returns API keys, mainly used for its side effects.
#' @export
#'
#' @examples
#' ql_set_api_keys("<your_api_keys_here>")
ql_set_api_keys <- function(api_keys) {
  if (!is.null(api_keys)) {
    Sys.setenv(quackingllama_api_keys = api_keys)
  }
  invisible(api_keys)
}

#' Retrieve previously set Ollama API keys typically used for cloud models
#'
#' @inheritParams ql_set_api_keys
#'
#' @returns API keys if previously set with `ql_set_api_keys()`, an empty string
#'   if not set, or the same keys provided as input to this function.
#' @export
#'
#' @examples
#' ql_set_api_keys("<your_api_keys_here>")
#' ql_get_api_keys()
ql_get_api_keys <- function(api_keys = NULL) {
  if (!is.null(api_keys)) {
    return(api_keys)
  }

  Sys.getenv("quackingllama_api_keys")
}
