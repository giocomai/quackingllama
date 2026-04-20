#' Translate strings relying on dedicated models
#'
#' @param text Text to be translated.
#' @param source_language Defaults to `NULL`. If not given, detected
#'   automatically. If `source_language_code` given, `source_language` is
#'   ignored. Source language as a full word, e.g. "English". For available
#'   languages with the default `translategemma` model, see the list of
#'   available languages in the
#'   \href{https://ollama.com/library/translategemma}{documentation on Ollama's
#'   website}.
#' @param source_language_code Defaults to `NULL`. If not given, detected
#'   automatically. If `source_language_code` given, `source_language` is
#'   ignored. Source language as a langauge code, e.g. "en", or "en-GB". For
#'   available languages with the default `translategemma` model, see the list of
#'   available languages in the
#'   \href{https://ollama.com/library/translategemma}{documentation on Ollama's
#'   website}.
#' @param target_language Defaults to `NULL`. If `target_language_code` given,
#'  `target_language` is ignored. Target language as a full word, e.g. "English".
#'  For available languages with the default `translategemma` model, see the
#'  list of available languages in the
#'   \href{https://ollama.com/library/translategemma}{documentation on Ollama's
#'   website}.
#' @param target_language_code Defaults to `en`. If not given, detected
#'   from  `target_language`. Either `target_language` or `target_language_code`
#'    must be given. Target language as a langauge code, e.g. "en", or "en-GB".
#'    For available languages with the default `translategemma` model, see the
#'    list of available languages in the
#' \href{https://ollama.com/library/translategemma}{documentation on Ollama's
#' website}.
#' @param translation_model Defaults to `translategemma:4b` (12b and 27 are also
#'   available). May work also with other models not specifically targeting
#'   translation.
#' @inheritParams ql_prompt
#' @inheritParams ql_generate
#'
#' @returns A data frame such as those returned by [ql_generate()] with the
#'   translation of the given input text in the response column.
#' @export
#'
#' @examples
#' \dontrun{
#' translation <- ql_translate(
#'   text = "A new collection of open translation models built on Gemma 3, helping people communicate across 55 languages.",
#'   target_language = "french"
#' )
#' translation$response
#' }
ql_translate <- function(
  text,
  source_language = NULL,
  source_language_code = NULL,
  target_language = NULL,
  target_language_code = NULL,
  translation_model = "translategemma:4b",
  temperature = NULL,
  seed = NULL,
  host = NULL,
  hash = TRUE,
  only_cached = FALSE,
  keep_alive = NULL,
  timeout = NULL,
  error = c("fail", "warn")
) {
  if (is.null(text)) {
    cli::cli_abort(message = "{.arg text} must be given.")
  } else if (tibble::is_tibble(text)) {
    text <- text |> dplyr::pull(response)
  }

  TEXT <- text

  if (is.null(target_language_code) & is.null(target_language)) {
    target_language_code <- "en"
  }

  if (is.null(target_language_code)) {
    TARGET_CODE <- dplyr::recode_values(
      x = stringr::str_to_lower(string = target_language),
      from = stringr::str_to_lower(translategemma_languages$language),
      to = stringr::str_to_lower(translategemma_languages$code)
    )
  } else {
    TARGET_CODE <- target_language_code
  }

  if (is.null(target_language)) {
    TARGET_LANG <- dplyr::recode_values(
      x = stringr::str_to_lower(string = target_language_code),
      from = stringr::str_to_lower(translategemma_languages$code),
      to = stringr::str_to_lower(translategemma_languages$language)
    ) |>
      stringr::str_to_title()
  } else {
    TARGET_LANG <- target_language |>
      stringr::str_to_title()
  }

  if (is.null(source_language_code) & is.null(source_language)) {
    source_language_code <- cld3::detect_language(text = text)
  }

  if (is.null(source_language)) {
    SOURCE_LANG <- dplyr::recode_values(
      x = stringr::str_to_lower(string = source_language_code),
      from = stringr::str_to_lower(translategemma_languages$code),
      to = stringr::str_to_lower(translategemma_languages$language)
    ) |>
      stringr::str_to_title()
  } else {
    SOURCE_LANG <- source_language |>
      stringr::str_to_title()
  }

  if (is.null(source_language_code)) {
    SOURCE_CODE <- dplyr::recode_values(
      x = stringr::str_to_lower(string = source_language),
      from = stringr::str_to_lower(translategemma_languages$language),
      to = stringr::str_to_lower(translategemma_languages$code)
    )
  } else {
    SOURCE_CODE <- source_language_code
  }

  prompt_message <- glue::glue(
    "You are a professional {SOURCE_LANG} ({SOURCE_CODE}) to {TARGET_LANG} ({TARGET_CODE}) translator. Your goal is to accurately convey the meaning and nuances of the original {SOURCE_LANG} text while adhering to {TARGET_LANG} grammar, vocabulary, and cultural sensitivities.
Produce only the {TARGET_LANG} translation, without any additional explanations or commentary. Please translate the following {SOURCE_LANG} text into {TARGET_LANG}:


{TEXT}"
  )

  ql_prompt(
    prompt = prompt_message,
    model = translation_model,
    think = FALSE,
    temperature = temperature,
    seed = seed,
    host = host,
    hash = hash
  ) |>
    ql_generate(
      only_cached = only_cached,
      host = host,
      messages = NULL,
      keep_alive = keep_alive,
      timeout = timeout,
      error = error
    )
}
