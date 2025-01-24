#' Hash all inputs relevant to the call to the LLM and create a hash to be used for caching.
#'
#' Mostly used internally.
#'
#' @param prompt_df A data frame with all inputs passed to the LLM, typically created with {ql_prompt()}.
#'
#' @returns
#' @export
#'
#' @examples
ql_hash <- function(prompt_df) {
  rlang::hash(prompt_df)
}
