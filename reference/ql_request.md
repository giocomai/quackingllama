# Create `httr2` request for both generate and chat endpoints

Create `httr2` request for both generate and chat endpoints

## Usage

``` r
ql_request(
  prompt_df,
  endpoint = "generate",
  host = NULL,
  messages = NULL,
  keep_alive = NULL,
  timeout = NULL
)
```

## Arguments

- endpoint:

  Defaults to "generate". Must be either "generate" or "chat".

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

## Value

A `httr2` request object.

## Examples

``` r
ql_prompt(prompt = "a haiku")
#> # A tibble: 1 × 8
#>   prompt  system                      think  seed temperature model format hash 
#>   <chr>   <chr>                       <lgl> <dbl>       <dbl> <chr> <chr>  <chr>
#> 1 a haiku You are a helpful assistan… NA        0           0 llam… ""     c57e…

ql_prompt(prompt = "a haiku") |>
  ql_request() |>
  httr2::req_dry_run()
#> POST /api/generate HTTP/1.1
#> accept: */*
#> accept-encoding: deflate, gzip, br, zstd
#> content-length: 188
#> content-type: application/json
#> host: localhost:11434
#> user-agent: httr2/1.2.2 r-curl/7.0.0 libcurl/8.5.0
#> 
#> {
#>   "model": "llama3.2",
#>   "prompt": "a haiku",
#>   "think": null,
#>   "images": null,
#>   "stream": false,
#>   "raw": false,
#>   "keep_alive": "5m",
#>   "options": {
#>     "seed": 0,
#>     "temperature": 0
#>   },
#>   "system": "You are a helpful assistant."
#> }
```
