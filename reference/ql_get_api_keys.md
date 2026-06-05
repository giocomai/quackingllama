# Retrieve previously set Ollama API keys typically used for cloud models

Retrieve previously set Ollama API keys typically used for cloud models

## Usage

``` r
ql_get_api_keys(api_keys = NULL)
```

## Arguments

- api_keys:

  Valid Ollama API keys, typically used for cloud models.

## Value

API keys if previously set with
[`ql_set_api_keys()`](https://giocomai.github.io/quackingllama/reference/ql_set_api_keys.md),
an empty string if not set, or the same keys provided as input to this
function.

## Examples

``` r
ql_set_api_keys("<your_api_keys_here>")
ql_get_api_keys()
#> [1] "<your_api_keys_here>"
```
