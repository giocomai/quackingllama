# Create a schema with one or more questions, and a single set of answers

Create a schema with one or more questions, and a single set of answers

## Usage

``` r
ql_create_schema_enum(questions, answers)
```

## Arguments

- questions:

  A character vector, of length 1 or more, with questions to be asked,
  usually about a text given as prompt.

- answers:

  A character vector: the response to each question should be one
  selected among the given options.

## Value

A list object, that can be passed to the `format` argument of
[ql_prompt](https://giocomai.github.io/quackingllama/reference/ql_prompt.md)

## Examples

``` r


library("quackingllama")
schema_l <- ql_create_schema_enum(
  questions = c(
    "Does this story include humans",
    "Does this story include animals",
    "Is this story about a woman",
    "Does this story have a happy ending"
  ),
  answers = c("Yes", "No", "Maybe", "Cannot answer")
)


schema_l
#> $type
#> [1] "object"
#> 
#> $properties
#> $properties$`Does this story include humans`
#> $properties$`Does this story include humans`$type
#> [1] "string"
#> 
#> $properties$`Does this story include humans`$enum
#> [1] "Yes"           "No"            "Maybe"         "Cannot answer"
#> 
#> 
#> $properties$`Does this story include animals`
#> $properties$`Does this story include animals`$type
#> [1] "string"
#> 
#> $properties$`Does this story include animals`$enum
#> [1] "Yes"           "No"            "Maybe"         "Cannot answer"
#> 
#> 
#> $properties$`Is this story about a woman`
#> $properties$`Is this story about a woman`$type
#> [1] "string"
#> 
#> $properties$`Is this story about a woman`$enum
#> [1] "Yes"           "No"            "Maybe"         "Cannot answer"
#> 
#> 
#> $properties$`Does this story have a happy ending`
#> $properties$`Does this story have a happy ending`$type
#> [1] "string"
#> 
#> $properties$`Does this story have a happy ending`$enum
#> [1] "Yes"           "No"            "Maybe"         "Cannot answer"
#> 
#> 
#> 
#> $required
#> [1] "Does this story include humans"      "Does this story include animals"    
#> [3] "Is this story about a woman"         "Does this story have a happy ending"
#> 

if (FALSE) { # \dontrun{
responses_df <- ql_prompt(
  prompt = "this it the story of a duck that escapes",
  format = schema_l,
) |>
  ql_generate() |>
  dplyr::pull("response") |>
  yyjsonr::read_json_str() |>
  tibble::as_tibble()

  responses_df



responses_df <- ql_prompt(
  prompt = "this it the story of a duck that escapes from a lady",
  format = schema_l
) |>
  ql_generate() |>
  dplyr::pull("response") |>
  yyjsonr::read_json_str() |>
  tibble::as_tibble()

  responses_df
} # }
```
