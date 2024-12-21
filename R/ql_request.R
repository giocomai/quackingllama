#' Create `httr2` request for both generate and chat endpoints
#'
#' @param endpoint Defaults to "generate". Must be either "generate" or "chat".
#'
#' @inheritParams ql_set_options
#'
#' @returns An httr2 request object.
#' @export
#'
#' @examples
#' ql_request(prompt = "a haiku")
#'
#' ql_request(prompt = "a haiku") |>
#'   httr2::req_dry_run()
ql_request <- function(prompt = NULL,
                       message = NULL,
                       format = NULL,
                       system = NULL,
                       host = NULL,
                       model = NULL,
                       temperature = NULL,
                       seed = NULL,
                       keep_alive = NULL,
                       endpoint = "generate") {
  rlang::arg_match(
    arg = endpoint,
    values = c(
      "generate",
      "chat",
      "api/generate",
      "api/chat"
    )
  )

  if (stringr::str_starts(
    string = endpoint,
    pattern = "api",
    negate = TRUE
  )) {
    endpoint <- stringr::str_c("api/", endpoint)
  }


  options_l <- ql_get_options(
    system = system,
    host = host,
    model = model,
    temperature = temperature,
    seed = seed
  )


  req_01 <- httr2::request(options_l[["host"]]) |>
    httr2::req_url_path(endpoint) |>
    httr2::req_headers("Content-Type" = "application/json")

  if (endpoint == "api/generate") {
    req_02 <- req_01 |>
      httr2::req_body_json(
        list(
          model = options_l[["model"]],
          prompt = prompt,
          format = format,
          stream = FALSE,
          raw = FALSE,
          options = list(
            seed = options_l[["seed"]],
            temperature = options_l[["temperature"]]
          ),
          system = options_l[["system"]]
        )
      )
  } else if (endpoint == "api/chat") {
    req_02 <- req_01 |>
      httr2::req_body_json(
        list(
          model = options_l[["model"]],
          prompt = prompt,
          messages = message,
          format = fields,
          stream = FALSE,
          raw = FALSE,
          options = list(
            seed = options_l[["seed"]],
            temperature = options_l[["temperature"]]
          )
        )
      )
  } else {
    cli::cli_abort(message = "The endpoint provided is not valid: {.val {endpoint}}")
  }

  req <- req_02 |>
    httr2::req_error(is_error = \(resp) FALSE)

  req
}
