#' Create `httr2` request for both generate and chat endpoints
#'
#' @param endpoint Defaults to "generate". Must be either "generate" or "chat".
#' @param timeout If not set with [ql_set_options()], defaults to 300 seconds (5
#'   minutes).
#' @param messages Defaults to NULL. If given, in line with official Ollama
#'   documentation: "the messages of the chat, this can be used to keep a chat
#'   memory".
#'
#' @inheritParams ql_set_options
#'
#' @returns A `httr2` request object.
#' @export
#'
#' @examples
#' ql_prompt(prompt = "a haiku")
#'
#' ql_prompt(prompt = "a haiku") |>
#'   ql_request() |>
#'   httr2::req_dry_run()
ql_request <- function(
  prompt_df,
  endpoint = "generate",
  host = NULL,
  messages = NULL,
  keep_alive = NULL,
  timeout = NULL
) {
  rlang::arg_match(
    arg = endpoint,
    values = c(
      "generate",
      "chat",
      "api/generate",
      "api/chat"
    )
  )

  if (
    stringr::str_starts(
      string = endpoint,
      pattern = "api",
      negate = TRUE
    )
  ) {
    endpoint <- stringr::str_c("api/", endpoint)
  }

  options_l <- ql_get_options(
    host = host,
    keep_alive = keep_alive,
    timeout = timeout
  )

  if (prompt_df[["format"]] == "") {
    format_schema <- NULL
  } else {
    format_schema <- prompt_df[["format"]]
  }

  req_01 <- httr2::request(options_l[["host"]]) |>
    httr2::req_url_path(endpoint) |>
    httr2::req_headers("Content-Type" = "application/json")

  if (endpoint == "api/generate") {
    if (is.null(format_schema)) {
      req_02 <- req_01 |>
        httr2::req_body_json(
          list(
            model = prompt_df[["model"]],
            prompt = prompt_df[["prompt"]],
            images = prompt_df[["images"]],
            stream = FALSE,
            raw = FALSE,
            keep_alive = options_l[["keep_alive"]],
            options = list(
              seed = prompt_df[["seed"]],
              temperature = prompt_df[["temperature"]]
            ),
            system = prompt_df[["system"]]
          )
        )
    } else {
      req_02 <- req_01 |>
        httr2::req_body_json(
          list(
            model = prompt_df[["model"]],
            prompt = prompt_df[["prompt"]],
            images = prompt_df[["images"]],
            format = yyjsonr::read_json_str(format_schema),
            stream = FALSE,
            raw = FALSE,
            keep_alive = options_l[["keep_alive"]],
            options = list(
              seed = prompt_df[["seed"]],
              temperature = prompt_df[["temperature"]]
            )
          )
        )
    }
  } else if (endpoint == "api/chat") {
    req_02 <- req_01 |>
      httr2::req_body_json(
        list(
          model = prompt_df[["model"]],
          prompt = prompt_df[["prompt"]],
          messages = messages,
          format = yyjsonr::read_json_str(format_schema),
          stream = FALSE,
          raw = FALSE,
          keep_alive = options_l[["keep_alive"]],
          options = list(
            seed = prompt_df[["seed"]],
            temperature = prompt_df[["temperature"]]
          )
        )
      )
  } else {
    cli::cli_abort(
      message = "The endpoint provided is not valid: {.val {endpoint}}"
    )
  }

  req <- req_02 |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_timeout(seconds = options_l[["timeout"]])

  req
}
