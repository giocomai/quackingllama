# Generate a response and return the result in a data frame

Generate a response and return the result in a data frame

## Usage

``` r
ql_generate(
  prompt_df,
  only_cached = FALSE,
  host = NULL,
  messages = NULL,
  keep_alive = NULL,
  timeout = NULL,
  error = c("fail", "warn")
)
```

## Arguments

- prompt_df:

  A data frame with all inputs passed to the LLM, typically created with
  [`ql_prompt()`](https://giocomai.github.io/quackingllama/reference/ql_prompt.md).

- only_cached:

  Defaults to `FALSE`. If `TRUE`, only cached responses are returned.

- host:

  The address where the Ollama API can be reached, e.g.
  `http://localhost:11434` for locally deployed Ollama.

- messages:

  Defaults to NULL. If given, in line with official Ollama
  documentation: "the messages of the chat, this can be used to keep a
  chat memory".

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

A data frame, including a response column, as well as other information
returned by the model.

## Examples

``` r
if (FALSE) { # \dontrun{
ql_prompt("a haiku") |>
  ql_generate()
  } # }
```
