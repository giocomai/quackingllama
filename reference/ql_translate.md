# Translate strings relying on dedicated models

Translate strings relying on dedicated models

## Usage

``` r
ql_translate(
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
)
```

## Arguments

- text:

  Text to be translated.

- source_language:

  Defaults to `NULL`. If not given, detected automatically. If
  `source_language_code` given, `source_language` is ignored. Source
  language as a full word, e.g. "English". For available languages with
  the default `translategemma` model, see the list of available
  languages in the [documentation on Ollama's
  website](https://ollama.com/library/translategemma).

- source_language_code:

  Defaults to `NULL`. If not given, detected automatically. If
  `source_language_code` given, `source_language` is ignored. Source
  language as a langauge code, e.g. "en", or "en-GB". For available
  languages with the default `translategemma` model, see the list of
  available languages in the [documentation on Ollama's
  website](https://ollama.com/library/translategemma).

- target_language:

  Defaults to `NULL`. If `target_language_code` given, `target_language`
  is ignored. Target language as a full word, e.g. "English". For
  available languages with the default `translategemma` model, see the
  list of available languages in the [documentation on Ollama's
  website](https://ollama.com/library/translategemma).

- target_language_code:

  Defaults to `en`. If not given, detected from `target_language`.
  Either `target_language` or `target_language_code` must be given.
  Target language as a langauge code, e.g. "en", or "en-GB". For
  available languages with the default `translategemma` model, see the
  list of available languages in the [documentation on Ollama's
  website](https://ollama.com/library/translategemma).

- translation_model:

  Defaults to `translategemma:4b` (12b and 27 are also available). May
  work also with other models not specifically targeting translation.

- temperature:

  Numeric value comprised between 0 and 1 passed to the model. When set
  to 0 and with the same seed, the response to the same prompt is always
  exactly the same. When closer to one, the response is more variable
  and creative. Use 0 for consistent responses. Setting this to 0.7 is a
  common choice for creative or interactive tasks.

- seed:

  An integer. When temperature is set to 0 and the seed is constant, the
  model consistently returns the same response to the same prompt.

- host:

  The address where the Ollama API can be reached, e.g.
  `http://localhost:11434` for locally deployed Ollama.

- hash:

  Defaults to `TRUE`. If `TRUE`, adds a column with the hash of all
  other components of the prompt. Used internally for caching. Can be
  added separately with
  [`ql_hash()`](https://giocomai.github.io/quackingllama/reference/ql_hash.md).

- only_cached:

  Defaults to `FALSE`. If `TRUE`, only cached responses are returned.

- keep_alive:

  Defaults to "5m". Controls how long the model will stay loaded into
  memory following the request.

- timeout:

  If not set with
  [`ql_set_options()`](https://giocomai.github.io/quackingllama/reference/ql_set_options.md),
  defaults to 300 seconds (5 minutes).

- error:

  Defines how errors should be handled, defaults to "fail", i.e. if an
  error emerges while querying the LLM, the function stops. If set to
  "warn", it sets the response to `NA_character_` and stores it in
  database. This can be useful e.g. for proceed if the prompts include a
  request that routinely time outs without giving a response. This does
  not imply that the model would never give a respones, e.g. re-running
  the same query with longer time out may work.

## Value

A data frame such as those returned by
[`ql_generate()`](https://giocomai.github.io/quackingllama/reference/ql_generate.md)
with the translation of the given input text in the response column.

## Examples

``` r
if (FALSE) { # \dontrun{
translation <- ql_translate(
  text = "A new collection of open translation models built on Gemma 3, helping people communicate across 55 languages.",
  target_language = "french"
)
translation$response
} # }
```
