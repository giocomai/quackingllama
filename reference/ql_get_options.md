# Get options

Get options

## Usage

``` r
ql_get_options(
  options = c("system", "model", "think", "host", "temperature", "seed", "keep_alive",
    "timeout"),
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

- options:

  A character vector used to filter which options should effectively be
  returned. Defaults to all available.

## Value

A list with all available options (or those selected with `options`)

## Examples

``` r

ql_set_options(
  model = "llama3.2",
  host = "http://localhost:11434",
  system = "You are a helpful assistant.",
  temperature = 0,
  seed = 42,
  keep_alive = "5m"
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
