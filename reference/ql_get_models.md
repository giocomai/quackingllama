# Get available models

Get available models

## Usage

``` r
ql_get_models(host = "http://localhost:11434")
```

## Arguments

- host:

  Defaults to "http://localhost:11434", where locally deployed Ollama
  usually responds.

## Value

A data frame (a tibble) with details on all locally available models.

## Examples

``` r
if (FALSE) { # \dontrun{
ql_get_models()
} # }
```
