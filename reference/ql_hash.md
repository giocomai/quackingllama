# Hash all inputs relevant to the call to the LLM and create a hash to be used for caching.

Mostly used internally.

## Usage

``` r
ql_hash(prompt_df)
```

## Arguments

- prompt_df:

  A data frame with all inputs passed to the LLM, typically created with
  [`ql_prompt()`](https://giocomai.github.io/quackingllama/reference/ql_prompt.md).

## Value

A tibble, such as those returned by
[`ql_prompt()`](https://giocomai.github.io/quackingllama/reference/ql_prompt.md),
but always including a hash column.

## Examples

``` r
ql_prompt("a haiku", hash = FALSE) |> ql_hash()
#> # A tibble: 1 × 8
#>   prompt  system                      think  seed temperature model format hash 
#>   <chr>   <chr>                       <lgl> <dbl>       <dbl> <chr> <chr>  <chr>
#> 1 a haiku You are a helpful assistan… NA        0           0 llam… ""     c57e…
```
