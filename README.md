
<!-- README.md is generated from README.Rmd. Please edit that file -->

# quackingllama <img src="man/figures/logo.png" align="right" height="240" alt="quackingllama logo - A llama with a duck mask in a hexagon" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of `quackingllama` is to facilitate efficient interactions with
LLMs; its current target use-case is text classification
(e.g. categorise or tag contents, or extract information from text). Key
features include:

- facilitate consistently formatted responses (through [Ollama’s
  structured ouputs](https://ollama.com/blog/structured-outputs))
- facilitate local caching (by storing results in a local `DuckDB`
  database)
- facilitate initiating text classification tasks (through examples and
  convenience functions)
- facilitate keeping a record with details about how each response has
  been received

## Installation

You can install the development version of `quackingllama` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("giocomai/quackingllama")
```

## Default options and outputs

In order to facilitate consistent results, by default `quackingllama`
sets the temperature of the model to 0: this means that it will always
return the same response when given the same prompt. When caching is
enabled, responses can then consistently be retrieved from the local
cache without querying again the LLMs.

All functions consistently return results in a data frame (a tibble).

Key functionalities will be demonstrated through a series of examples.

As the package is developed further, some of the less intuitive tasks
(e.g. defining a schema) will be facilitated through dedicated
convenience functions.

## Basic examples

### Text generation

``` r
library("quackingllama")
```

Let’s generate a short piece of text. Results are returned in a data
frame, with the `response` in the first column and all relevant metadata
about the query stored along with it.

``` r
pol_df <- ql_generate(prompt = "Describe an imaginary political leader in less than 100 words.")

str(pol_df)
#> tibble [1 × 15] (S3: tbl_df/tbl/data.frame)
#>  $ response            : chr "Meet Aurora \"Rory\" Thompson, the charismatic and progressive leader of the coastal nation of Azura. A former "| __truncated__
#>  $ prompt              : chr "Describe an imaginary political leader in less than 100 words."
#>  $ model               : chr "llama3.2"
#>  $ created_at          : chr "2024-12-22T22:47:49.804294268Z"
#>  $ done                : logi TRUE
#>  $ done_reason         : chr "stop"
#>  $ total_duration      : num 5.51e+09
#>  $ load_duration       : int 1960027309
#>  $ prompt_eval_count   : int 43
#>  $ prompt_eval_duration: int 264000000
#>  $ eval_count          : int 118
#>  $ eval_duration       : num 3.29e+09
#>  $ system              : chr "You are a helpful assistant."
#>  $ seed                : int 1616140768
#>  $ temperature         : int 0
```

``` r
pol_df$response
#> [1] "Meet Aurora \"Rory\" Thompson, the charismatic and progressive leader of the coastal nation of Azura. A former environmental activist turned politician, Rory is known for her unwavering commitment to sustainability and social justice. With a warm smile and infectious laugh, she has won over the hearts of her constituents with her inclusive policies and bold vision for a greener future. As President of Azura, Rory has made it her mission to protect the planet while promoting economic growth and equality for all citizens. Her leadership style is collaborative, empathetic, and unapologetically forward-thinking."
```

If we are interested in variations of this text, we can easily create
them:

``` r
# TODO accept multiple prompts by default

pol3_df <- purrr::map(
  .x = c("progressive", "conservative", "centrist"),
  .f = \(x) {
    ql_generate(prompt = glue::glue("Describe an imaginary {x} politician in less than 100 words."))
  }
) |>
  purrr::list_rbind()

pol3_df$response
#> [1] "Meet Maya Ramos, a charismatic and visionary leader who embodies the values of social justice and environmental sustainability. As a former community organizer and small business owner, Maya understands the needs of everyday people and is committed to creating economic opportunities that lift up marginalized communities. Her progressive platform prioritizes affordable healthcare, free public education, and a Green New Deal that invests in renewable energy and sustainable infrastructure. With her warm smile and infectious passion, Maya inspires a new generation of activists and voters to join the fight for a more just and equitable society."
#> [2] "Meet Reginald P. Bottomsworth, a stalwart conservative politician from rural America. A third-generation farmer and small business owner, Reggie is known for his down-to-earth values and no-nonsense approach to governance. He supports traditional industries like agriculture and manufacturing, and advocates for limited government intervention in personal and economic matters. With a folksy demeanor and a strong work ethic, Reggie has built a loyal following among conservative voters who appreciate his commitment to preserving American traditions and individual freedoms. His slogan? \"Common sense, not Washington wisdom.\""                   
#> [3] "Meet Alexandra \"Alex\" Thompson, a pragmatic and moderate politician. A former business owner turned public servant, Alex brings a unique blend of fiscal responsibility and social compassion to the table. She advocates for balanced budgets, tax reform, and investments in education and infrastructure. However, she also prioritizes affordable healthcare, environmental protection, and social justice. With a calm and collected demeanor, Alex is able to bridge partisan divides and find common ground with her constituents. Her centrist approach has earned her a reputation as a trusted mediator and problem-solver in the halls of power."
```

These are, as it is the customary default behaviour of LLMs, free form
texts. Depending on the task at hand, we may want to have text in a more
structured format. To do so, we must provide the LLM with a
[schema](https://json-schema.org/) of how we want it to to return data.

Schema can be very simple, e.g., if we want our response to feature only
a “name” and “description” field, and both should be character strings,
we’d use the following schema:

``` r
# TODO convenience function to facilitate creation of common schemas

schema <- list(
  type = "object",
  properties = list(
    `name` = list(type = "string"),
    `description` = list(type = "string")
  ),
  required = c("name", "description")
)
```

``` r
pol_schema_df <- ql_generate(
  prompt = "Describe an imaginary political leader.",
  format = schema
)

pol_schema_df$response |>
  yyjsonr::read_json_str()
#> $name
#> [1] "Aurora Wynter"
#> 
#> $description
#> [1] "Aurora Wynter is a charismatic and visionary leader who has captivated the hearts of her people with her unwavering commitment to justice, equality, and environmental sustainability. Born in the coastal city of Newhaven, Aurora grew up surrounded by the beauty and fragility of the ocean, which instilled in her a deep love for the natural world and a fierce determination to protect it from harm. As a young woman, she became an outspoken advocate for climate action, using her powerful voice to raise awareness about the urgent need for sustainable practices and renewable energy sources. Her message resonated with people of all ages and backgrounds, earning her a reputation as a passionate and authentic leader who is not afraid to challenge the status quo. Aurora's leadership style is characterized by her collaborative approach, which brings together diverse stakeholders to find innovative solutions to complex problems. She is known for her ability to listen deeply and empathetically, often finding common ground with even the most unlikely of opponents. Despite facing numerous challenges and setbacks throughout her career, Aurora remains steadfast in her commitment to creating a better world for all, inspiring countless individuals around the globe to join her on this journey towards a brighter future."
```

or slightly more complex, for example making clear that we expect a
field to be numeric, and another one to pick between one of a set of
options:

``` r
schema <- list(
  type = "object",
  properties = list(
    `name` = list(type = "string"),
    `age` = list(type = "number"),
    `gender` = list(
      type = "string",
      enum = c("female", "male", "non-binary")
    ),
    `motto` = list(type = "string"),
    `description` = list(type = "string")
  ),
  required = c(
    "name",
    "age",
    "gender",
    "motto",
    "description"
  )
)
```

And the returned is formatted as expected:

``` r
pol_schema_df <- ql_generate(
  prompt = "Describe an imaginary political leader.",
  format = schema
)

pol_schema_df$response |>
  yyjsonr::read_json_str()
#> $name
#> [1] "Aurora Wynter"
#> 
#> $age
#> [1] 52
#> 
#> $gender
#> [1] "female"
#> 
#> $motto
#> [1] "Unity in Diversity, Progress through Inclusion"
#> 
#> $description
#> [1] "Aurora Wynter is a charismatic and visionary leader who has captivated the hearts of her people. Born into a family of modest means, she rose to prominence as a grassroots activist, fighting for social justice and equality. Her unwavering commitment to these values has earned her the respect and admiration of her constituents. With a warm smile and an infectious laugh, Aurora exudes confidence and compassion, inspiring those around her to work towards a brighter future."
```

Having the response in a structured format allows for easily storing
results in a data frame and processing them further.

``` r
pol3_schema_df <- purrr::map(
  .x = c("progressive", "conservative", "centrist"),
  .f = \(x) {
    ql_generate(
      prompt = glue::glue("Describe an imaginary {x} politician."),
      format = schema
    )
  }
) |>
  purrr::list_rbind()

pol3_schema_responses_df <- purrr::map(
  .x = pol3_schema_df$response,
  .f = \(x) {
    yyjsonr::read_json_str(x) |>
      tibble::as_tibble()
  }
) |>
  purrr::list_rbind()

pol3_schema_responses_df
#> # A tibble: 3 × 5
#>   name                       age gender motto                        description
#>   <chr>                    <int> <chr>  <chr>                        <chr>      
#> 1 Maya Ramos                  42 female Empowering a Just and Equit… Maya Ramos…
#> 2 Reginald P. Bottomsworth    55 male   Tradition, Progress, and Pr… A seasoned…
#> 3 Alexander Thompson          52 male   Pragmatic Progress           Alexander …
```

This has obvious advantages for many data processing tasks, and, as will
be seen, can effectively be used to enhance the consistency of text
classification tasks. But first, let’s discuss caching and some of the
options that determine output.

### Caching and options

TODO

### Text classification

TODO

## About the hex logo

In the logo you may or may not recognise a quacking llama, or maybe,
just a llama wearing a duck mask. The reference is obviously to two of
the main tools used by this package: [`ollama`](https://ollama.com/) and
[`DuckDB`](https://duckdb.org/docs/api/r.html). Image generated on my
machine with `stablediffusion`.
