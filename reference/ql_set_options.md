# Set basic options for the current session.

Set basic options for the current session.

## Usage

``` r
ql_set_options(
  system = NULL,
  model = NULL,
  think = NULL,
  host = NULL,
  temperature = NULL,
  seed = NULL,
  keep_alive = NULL,
  timeout = NULL
)
```

## Arguments

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

- host:

  The address where the Ollama API can be reached, e.g.
  `http://localhost:11434` for locally deployed Ollama.

- temperature:

  Numeric value comprised between 0 and 1 passed to the model. When set
  to 0 and with the same seed, the response to the same prompt is always
  exactly the same. When closer to one, the response is more variable
  and creative. Use 0 for consistent responses. Setting this to 0.7 is a
  common choice for creative or interactive tasks.

- seed:

  An integer. When temperature is set to 0 and the seed is constant, the
  model consistently returns the same response to the same prompt.

- keep_alive:

  Defaults to "5m". Controls how long the model will stay loaded into
  memory following the request.

- timeout:

  Time in seconds before the request times out. Defaults to 300
  (corresponding to 5 minutes).

## Value

Nothing, used for its side effects. Options can be retrieved with
[`ql_get_db_options()`](https://giocomai.github.io/quackingllama/reference/ql_get_db_options.md)

## Examples

``` r
ql_set_options(
  model = "llama3.2",
  host = "http://localhost:11434",
  system = "You are a helpful assistant.",
  temperature = 0,
  seed = 42
)

ql_get_options()
#> $system
#> [1] "You are a helpful assistant."
#> 
#> $model
#> [1] "llama3.2"
#> 
#> $think
#> [1] NA
#> 
#> $host
#> [1] "http://localhost:11434"
#> 
#> $temperature
#> [1] 0
#> 
#> $seed
#> [1] 42
#> 
#> $keep_alive
#> [1] "5m"
#> 
#> $timeout
#> [1] 300
#> 
```
