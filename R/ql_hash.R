#' Hash all inputs relevant to the call to the LLM and create a hash to be used
#' for caching.
#'
#' Mostly used internally.
#'
#' @param prompt_df A data frame with all inputs passed to the LLM, typically
#'   created with [ql_prompt()].
#'
#' @returns A tibble, such as those returned by [ql_prompt()], but always
#'   including a hash column.
#' @export
#'
#' @examples
#' ql_prompt("a haiku", hash = FALSE) |> ql_hash()
ql_hash <- function(prompt_df) {
  if ("hash" %in% colnames(prompt_df)) {
    prompt_df
  } else {
    dplyr::bind_cols(
      prompt_df,
      purrr::map_chr(
        .progress = "Calculating hashes",
        .x = purrr::transpose(.l = prompt_df),
        .f = \(current_prompt) {
          rlang::hash(current_prompt)
        }
      ) |>
        tibble::enframe(name = NULL, value = "hash")
    )
  }
}
