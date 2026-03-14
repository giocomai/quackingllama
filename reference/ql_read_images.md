# Read image in order to pass it to multimodal models

Read image in order to pass it to multimodal models

## Usage

``` r
ql_read_images(path)
```

## Arguments

- path:

  Path to image file.

## Value

A list object of character vectors of base 64 encoded images.

## Examples

``` r
if (interactive()) {
  library("quackingllama")

  img_path <- fs::file_temp(ext = "png")

  download.file(
    url = "https://ollama.com/public/ollama.png",
    destfile = img_path
  )

  resp_df <- ql_prompt(
    prompt = "what is this?",
    images = img_path,
    model = "llama3.2-vision"
  ) |>
    ql_generate()

  resp_df

  resp_df$response
}
```
