#' Create a schema with one or more questions, and a single set of answers
#'
#' @param questions A character vector, of length 1 or more, with questions to be asked, usually about a text given as prompt.
#' @param answers A character vector: the response to each question should be one selected among the given options.
#'
#' @returns A list object, that can be passed to the `format` argument of [ql_prompt]
#' @export
#'
#' @examples
#'
#'
#' library("quackingllama")
#' schema_l <- ql_create_schema_enum(
#'   questions = c(
#'     "Does this story include humans",
#'     "Does this story include animals",
#'     "Is this story about a woman",
#'     "Does this story have a happy ending"
#'   ),
#'   answers = c("Yes", "No", "Maybe", "Cannot answer")
#' )
#'
#'
#' schema_l
#'
#' \dontrun{
#' responses_df <- ql_prompt(
#'   prompt = "this it the story of a duck that escapes",
#'   format = schema_l,
#' ) |>
#'   ql_generate() |>
#'   dplyr::pull("response") |>
#'   yyjsonr::read_json_str() |>
#'   tibble::as_tibble()
#'
#'   responses_df
#'
#'
#'
#' responses_df <- ql_prompt(
#'   prompt = "this it the story of a duck that escapes from a lady",
#'   format = schema_l
#' ) |>
#'   ql_generate() |>
#'   dplyr::pull("response") |>
#'   yyjsonr::read_json_str() |>
#'   tibble::as_tibble()
#'
#'   responses_df
#' }

ql_create_schema_enum <- function(questions, answers) {
  properties_l <- purrr::map(
    rlang::set_names(questions),
    ~ list(
      type = "string",
      enum = answers
    )
  )

  properties_l <- setNames(
    purrr::map(
      .x = questions,
      \(q) {
        list(
          type = "string",
          enum = answers
        )
      }
    ),
    questions
  )

  schema_l <- list(
    type = "object",
    properties = rlang::list2(
      !!!properties_l
    ),
    required = questions
  )

  schema_l
}
