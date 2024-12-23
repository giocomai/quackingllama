
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
#> tibble [1 × 16] (S3: tbl_df/tbl/data.frame)
#>  $ response            : chr "Meet Aurora \"Rory\" Thompson, the charismatic and progressive leader of the coastal nation of Azura. A former "| __truncated__
#>  $ prompt              : chr "Describe an imaginary political leader in less than 100 words."
#>  $ model               : chr "llama3.2"
#>  $ created_at          : chr "2024-12-23T22:03:57.89954051Z"
#>  $ done                : logi TRUE
#>  $ done_reason         : chr "stop"
#>  $ total_duration      : num 3.81e+09
#>  $ load_duration       : num 19063527
#>  $ prompt_eval_count   : num 43
#>  $ prompt_eval_duration: num 7.6e+07
#>  $ eval_count          : num 118
#>  $ eval_duration       : num 3.71e+09
#>  $ system              : chr "You are a helpful assistant."
#>  $ seed                : int 1312976429
#>  $ temperature         : num 0
#>  $ format              : chr ""
```

``` r
cat(">", pol_df$response)
```

> Meet Aurora “Rory” Thompson, the charismatic and progressive leader of
> the coastal nation of Azura. A former environmental activist turned
> politician, Rory is known for her unwavering commitment to
> sustainability and social justice. With a warm smile and infectious
> laugh, she has won over the hearts of her constituents with her
> inclusive policies and bold vision for a greener future. As President
> of Azura, Rory has made it her mission to protect the planet while
> promoting economic growth and equality for all citizens. Her
> leadership style is collaborative, empathetic, and unapologetically
> forward-thinking.

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

So far, local caching has not been enabled: this means that even when
the exacts same response is expected, this will still be requested to
the LLM, which can be exceedingly time-consuming especially for
repetitive tasks, or for data processing pipelines that may recurrently
encounter the same data.

Caching is the obvious answer to this process, but when do we expect
exactly the same response from the LLM, considering that LLMs do not
necessarily return the same response even when given the same prompt?

Two parameters are particularly relevant for understanding this,
`temperature` and `seed`.

What is “temperature”? [Ollama’s
documentation](https://github.com/ollama/ollama/blob/main/docs/modelfile.md#valid-parameters-and-values)
concisely clarifies the effect of this parameter by suggesting that
“Increasing the temperature will make the model answer more creatively.”
LLMs often have the default temperature set to 0.7 or 0.8. In brief,
when temperature is set to its maximum value of 1, the LLMs will provide
more varied responses. When temperature is set to 0, the LLMs are at
their more consistent: they always provide the same response to the same
prompt.

What does it mean in practices? For example, that if I set the
temperature to 0 and ask the same LLM to generate a haiku, I will always
get the very same haiku, no matter how many times I run this command.

``` r
ql_generate(prompt = "A funny haiku", temperature = 0)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Tacos on my face\nS… A fun… llam… 2024-12-2… TRUE  stop             788379516
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 0)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Tacos on my face\nS… A fun… llam… 2024-12-2… TRUE  stop             788379516
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 0)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Tacos on my face\nS… A fun… llam… 2024-12-2… TRUE  stop             788379516
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
```

If I set the temperature to 1, I get every time a different haiku (ok,
not very different, really, but still different).

``` r
ql_generate(prompt = "A funny haiku", temperature = 1)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Here's one:\n\nPizz… A fun… llam… 2024-12-2… TRUE  stop             813279017
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 1)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Pants that fall at … A fun… llam… 2024-12-2… TRUE  stop             647547383
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 1)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Taco Tuesday fails\… A fun… llam… 2024-12-2… TRUE  stop             485106215
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
```

But then, replicability of results is possible even when the temperature
is set to a value higher than 0. We just need to set the same seed, and
we’ll consistently get the same result.

``` r
ql_generate(prompt = "A funny haiku", temperature = 1, seed = 2024)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Fart in crowded pla… A fun… llam… 2024-12-2… TRUE  stop             578921598
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 1, seed = 2024)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Fart in crowded pla… A fun… llam… 2024-12-2… TRUE  stop             578921598
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
ql_generate(prompt = "A funny haiku", temperature = 1, seed = 2024)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Fart in crowded pla… A fun… llam… 2024-12-2… TRUE  stop             578921598
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
```

Two additional components determine if the response is exactly the same
in different instances: `system` and `format`. The `system` parameter is
passed along with the prompt to the LLM, and by default is set to the
generic “You are a helpful assistant.”. This is a reasonable generic
option, but there may be good reasons to be more specific depending on
the task at hand.

For example, if we set as the system message “You are an 18th century
poet.”, the style of the response will change (somewhat) accordingly.

``` r
ql_generate(
  prompt = "A funny haiku",
  temperature = 0,
  system = "You are an 18th century poet."
)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Fart doth echo loud… A fun… llam… 2024-12-2… TRUE  stop             806179886
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
```

As discussed above, `format` is relevant only for instances when a
structured output is requested to the LLM by providing a schema. For
example, if we provided a different schema, the output would also have
been different.

``` r
schema <- list(
  type = "object",
  properties = list(
    `haiku` = list(type = "string"),
    `why_funny` = list(type = "string")
  ),
  required = c(
    "haiku",
    "why_funny"
  )
)

haiku_str_df <- ql_generate(
  prompt = "Write a funny haiku, and explain why it is supposed to be funny.",
  format = schema
)

haiku_str_df |>
  dplyr::pull(response) |>
  yyjsonr::read_json_str()
#> $haiku
#> [1] "I fart in space"
#> 
#> $why_funny
#> [1] "This haiku is meant to be humorous because it takes a common bodily function (farting) and combines it with an unexpected setting (space). The juxtaposition of the mundane and the extraordinary creates a comedic effect. Additionally, the simplicity and brevity of the haiku make the punchline more impactful."
```

In brief, when should we expect to receive exactly the same response
from the LLM, hence, making it possible to retrieve it from cache if
already parsed? The following conditions must apply:

- same model
- same `system` parameter
- same `format`, i.e., same schema (if given).
- same prompt
- and
  - either the same seed and any value for `temperature` OR
  - any seed and `temperature` set to zero

If the above conditions are met, and caching is enabled, the response
will be retrieved from the local cache, rather than from the LLM.

It’s easy to enable caching for the current session with
`ql_enable_db()`. By default, the database is stored in the current
working directory, but this can be changed with `ql_set_db_options()`.

``` r
ql_enable_db()
ql_set_db_options(db_folder = fs::path_home_r("R"))
```

Now even prompts that would take the LLM many seconds to process can be
returned efficiently from cache:

``` r
invisible(
  ql_generate(
    prompt = "A long story",
    temperature = 1,
    system = "You are an 18th century poet.",
    seed = 42
  )
)

before <- Sys.time()
ql_generate(
  prompt = "A long story",
  temperature = 1,
  system = "You are an 18th century poet.",
  seed = 42
)
#> # A tibble: 1 × 16
#>   response              prompt model created_at done  done_reason total_duration
#>   <chr>                 <chr>  <chr> <chr>      <lgl> <chr>                <dbl>
#> 1 "Fair reader, thou s… A lon… llam… 2024-12-2… TRUE  stop           17586201634
#> # ℹ 9 more variables: load_duration <dbl>, prompt_eval_count <dbl>,
#> #   prompt_eval_duration <dbl>, eval_count <dbl>, eval_duration <dbl>,
#> #   system <chr>, seed <int>, temperature <dbl>, format <chr>
after <- Sys.time()

after - before
#> Time difference of 0.3070652 secs
```

### Text classification

TODO

## About the hex logo

In the logo you may or may not recognise a quacking llama, or maybe,
just a llama wearing a duck mask. The reference is obviously to two of
the main tools used by this package: [`ollama`](https://ollama.com/) and
[`DuckDB`](https://duckdb.org/docs/api/r.html). Image generated on my
machine with `stablediffusion`.
