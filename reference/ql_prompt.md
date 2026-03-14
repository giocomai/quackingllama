# Generate a data frame with all relevant inputs for the LLM.

Typically passed to
[`ql_generate()`](https://giocomai.github.io/quackingllama/reference/ql_generate.md).

## Usage

``` r
ql_prompt(
  prompt,
  system = NULL,
  format = NULL,
  model = NULL,
  think = NULL,
  images = NULL,
  temperature = NULL,
  seed = NULL,
  host = NULL,
  hash = TRUE
)
```

## Arguments

- prompt:

  A prompt for the LLM.

- system:

  System message to pass to the model. See official documentation for
  details. For example: "You are a helpful assistant."

- model:

  The name of the model, e.g. `llama3.2` or `phi3.5:3.8b`. Run
  `ollama list` from the command line to see a list of locally available
  models.

- think:

  If TRUE, Ollama enables thinking mode for models which support it. For
  more information, see [Ollama's announcement of 'thinking'
  capabilities](https://ollama.com/blog/thinking).

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

  Defaults to TRUE. If TRUE, adds a column with the hash of all other
  components of the prompt. Used internally for caching. Can be added
  separately with
  [`ql_hash()`](https://giocomai.github.io/quackingllama/reference/ql_hash.md).

## Value

A tibble with all main components of a query, to be passed to
[`ql_generate()`](https://giocomai.github.io/quackingllama/reference/ql_generate.md).

## Details

For more details and context about each parameter, see
<https://github.com/ollama/ollama/blob/main/docs/api.md>.

## Examples

``` r
ql_prompt("a haiku")
#> # A tibble: 1 × 8
#>   prompt  system                      think  seed temperature model format hash 
#>   <chr>   <chr>                       <lgl> <dbl>       <dbl> <chr> <chr>  <chr>
#> 1 a haiku You are a helpful assistan… NA        0           0 llam… ""     c57e…
```
