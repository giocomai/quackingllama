
<!-- README.md is generated from README.Rmd. Please edit that file -->

# quackingllama <img src="man/figures/logo.png" align="right" height="240" alt="quackingllama logo - A llama with a duck mask in a hexagon" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of `quackingllama` is to facilitate processing text with
Ollama, and store results in DuckDB.

For example: you need to categorise or tag contents, but don’t want to
take care of the caching… `quackingllama` is there to make things
easier.

Coming soon.

## Installation

You can install the development version of `quackingllama` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("giocomai/quackingllama")
```

## Example

``` r
library("quackingllama")
```

### About the hex logo

In the logo you may or may not recognise a quacking llama, or maybe,
just a llama wearing a duck mask. The reference is obviously to two of
the main tools used by this package: [`ollama`](https://ollama.com/) and
[`DuckDB`](https://duckdb.org/docs/api/r.html). Image generated on my
machine with `stablediffusion`.
