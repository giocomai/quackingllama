
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
pol_df <- ql_prompt(prompt = "Describe an imaginary political leader in less than 100 words.") |>
  ql_generate()

str(pol_df)
#> tibble [1 × 17] (S3: tbl_df/tbl/data.frame)
#>  $ response            : chr "Meet Aurora \"Rory\" Thompson, the charismatic and progressive leader of the coastal nation of Azura. A former "| __truncated__
#>  $ prompt              : chr "Describe an imaginary political leader in less than 100 words."
#>  $ model               : chr "llama3.2"
#>  $ created_at          : chr "2025-01-24T10:33:17.253671092Z"
#>  $ done                : logi TRUE
#>  $ done_reason         : chr "stop"
#>  $ total_duration      : num 2.81e+09
#>  $ load_duration       : num 19382578
#>  $ prompt_eval_count   : num 43
#>  $ prompt_eval_duration: num 4.8e+07
#>  $ eval_count          : num 118
#>  $ eval_duration       : num 2.74e+09
#>  $ system              : chr "You are a helpful assistant."
#>  $ seed                : num 0
#>  $ temperature         : num 0
#>  $ format              : chr ""
#>  $ hash                : chr "80514baa233dba4997c4f2dcbdc8557d"
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
    ql_prompt(prompt = glue::glue("Describe an imaginary {x} politician in less than 100 words.")) |>
      ql_generate()
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
pol_schema_df <- ql_prompt(
  prompt = "Describe an imaginary political leader.",
  format = schema
) |>
  ql_generate()

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
pol_schema_df <- ql_prompt(
  prompt = "Describe an imaginary political leader.",
  format = schema
) |>
  ql_generate()

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
    ql_prompt(
      prompt = glue::glue("Describe an imaginary {x} politician."),
      format = schema
    ) |>
      ql_generate()
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
ql_prompt(prompt = "A reasonably funny haiku", temperature = 0) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Tacos on my face\nSalsa drips from happy lips\nMidlife crisis born"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 0) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Tacos on my face\nSalsa drips from happy lips\nMidlife crisis born"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 0) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Tacos on my face\nSalsa drips from happy lips\nMidlife crisis born"
```

If I set the temperature to 1, I get every time a different haiku (ok,
not very different, really, but still different).

``` r
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Farting on my toe\nSilent-but-deadly revenge\nGassy little joke"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pizza in my pants\nCheesy dreams and joyful mess\nLaughter's warm delight"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pants fall down at night\nSilent, sloppy, I confess\nMorning's bitter laugh"
```

But then, replicability of results is possible even when the temperature
is set to a value higher than 0. We just need to set the same seed, and
we’ll consistently get the same result.

``` r
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1, seed = 2025) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pizza in my lap\nMelted cheese and happy sigh\nLife's simple delight"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1, seed = 2025) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pizza in my lap\nMelted cheese and happy sigh\nLife's simple delight"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1, seed = 2025) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pizza in my lap\nMelted cheese and happy sigh\nLife's simple delight"
```

Two additional components determine if the response is exactly the same
in different instances: `system` and `format`. The `system` parameter is
passed along with the prompt to the LLM, and by default is set to the
generic “You are a helpful assistant.”. This is a reasonable generic
option, but there may be good reasons to be more specific depending on
the task at hand.

For example, if we set as the system message “You are a 19th century
romantic poet.”, the style of the response will change (somewhat)
accordingly.

``` r
ql_prompt(
  prompt = "A reasonably funny haiku",
  temperature = 0,
  system = "You are a 19th century romantic writer."
) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Fop's ridiculous hat\nTops his lumpy, love-struck face\nSighs of wretched bliss"
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

haiku_str_df <- ql_prompt(
  prompt = "Write a funny haiku, and explain why it is supposed to be funny.",
  format = schema
) |> ql_generate()

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

### Text classification

First, let’s create some texts that we will then try to classify:

``` r
schema <- list(
  type = "object",
  properties = list(
    `party name` = list(type = "string"),
    `political leaning` = list(
      type = "string",
      enum = c("progressive", "conservative")
    ),
    `political statement` = list(type = "string")
  ),
  required = c(
    "party name",
    "political leaning",
    "political statement"
  )
)

parties_df <- purrr::map2(
  .x = rep(c("progressive", "conservative"), 5),
  .y = 1:10,
  .f = \(x, y) {
    ql_prompt(
      prompt = glue::glue("Describe an imaginary {x} political party, inventing their party name and a characteristic political statement."),
      format = schema,
      temperature = 1,
      seed = y
    ) |>
      ql_generate()
  }
) |>
  purrr::list_rbind()

parties_responses_df <- purrr::map(
  .x = parties_df$response,
  .f = \(x) {
    yyjsonr::read_json_str(x) |>
      tibble::as_tibble()
  }
) |>
  purrr::list_rbind()

parties_responses_df
#> # A tibble: 10 × 3
#>    `party name`                    `political leaning` `political statement`    
#>    <chr>                           <chr>               <chr>                    
#>  1 The Luminari Party              progressive         "Embracing a global citi…
#>  2 The Liberty Rebirth Party (LRP) conservative        " 'Restoring the Foundin…
#>  3 Eunoia Party                    progressive         "We believe that 'eudaim…
#>  4 Libertarian Progressives        conservative        "Balancing Tradition wit…
#>  5 The Luminari                    progressive         " 'We are the torchbeare…
#>  6 Libertas Novi                   conservative        "We believe that the Uni…
#>  7 Eudaimonia                      progressive         "We believe that the gre…
#>  8 The Terra Vita Party            conservative        "Emphasizing the importa…
#>  9 The Luminari Party              progressive         "We believe that technol…
#> 10 The New Order Party (NOP)       conservative        "Protecting Traditional …
```

Then we ask a different model to categorise results (in this example,
text generation with `llama3.2`, text categorisation with `mistral`).
Trimming explanations in the following table for clarity.

``` r
category_schema <- list(
  type = "object",
  properties = list(
    `political leaning` = list(
      type = "string",
      enum = c("progressive", "conservative")
    ),
    `explanation` = list(type = "string")
  ),
  required = c(
    "political leaning",
    "explanation"
  )
)

categories_df <- purrr::map(
  .x = parties_responses_df[["political statement"]],
  .f = \(current_statement) {
    ql_prompt(
      prompt = current_statement,
      system = "You identify the political leaning of political parties based on their statements.",
      format = category_schema,
      temperature = 0,
      model = "mistral"
    ) |>
      ql_generate()
  }
) |>
  purrr::list_rbind()

categories_responses_df <- purrr::map(
  .x = categories_df$response,
  .f = \(x) {
    yyjsonr::read_json_str(x) |>
      tibble::as_tibble()
  }
) |>
  purrr::list_rbind()



responses_combo_df <- dplyr::bind_cols(
  parties_responses_df |>
    dplyr::rename(`given political leaning` = `political leaning`) |>
    dplyr::select(`political statement`, `given political leaning`),
  categories_responses_df |>
    dplyr::rename(`identified political leaning` = `political leaning`)
)

responses_combo_df |>
  dplyr::mutate(explanation = stringr::str_trunc(explanation, width = 256)) |>
  knitr::kable()
```

| political statement | given political leaning | identified political leaning | explanation |
|:---|:---|:---|:---|
| Embracing a global citizenry through the universal basic income, sustainable development and intergenerational justice. | progressive | progressive | This statement suggests a progressive political leaning, as it advocates for policies that prioritize the well-being of all people worldwide (universal basic income), promote sustainable development, and ensure fairness across generations (intergenerati… |
| ‘Restoring the Founding Principles: Limited Government, Personal Responsibility, and Traditional Values’ | conservative | conservative | This title suggests a focus on restoring principles that are traditionally associated with conservative politics. The three key areas mentioned are: Limited Government, Personal Responsibility, and Traditional Values. Here’s a brief explanation of each:… |
| We believe that ‘eudaimonia’ – the ancient Greek concept of living a fulfilling life – is the guiding principle for our society, where everyone has access to quality education, healthcare, and economic opportunities, and can live in harmony with themselves and the planet. | progressive | progressive | The belief that ‘Eudaimonia’ – the ancient Greek concept of living a fulfilling life – should be the guiding principle for society, emphasizes the importance of providing quality education, healthcare, and economic opportunities to all individuals. This… |
| Balancing Tradition with Innovation | conservative | progressive | Balancing tradition with innovation means finding a harmonious blend of respecting and preserving the values, customs, and practices of the past while embracing new ideas, technologies, and methods that can improve and advance society. This approach req… |
| ‘We are the torchbearers of a brighter future: A future where technology serves humanity, not the other way around; where economic growth is equitable and sustainable; where justice and equality are the guiding principles that shape our society.’ | progressive | progressive | This statement expresses a progressive political viewpoint. The speaker advocates for a future in which technology benefits humanity, economic growth is equitable and sustainable, and justice and equality are prioritized in society. This perspective emp… |
| We believe that the United States is at its strongest when it maintains a strong sense of self-reliance, limited government intervention, and unwavering commitment to traditional values. | conservative | conservative | The statement suggests a conservative political stance that emphasizes individualism, minimal government interference, and adherence to traditional values. This perspective is often associated with the belief that self-reliance and limited government in… |
| We believe that the greatest wealth of any nation is not measured by its GDP or GDP per capita, but rather by the well-being and flourishing of all its citizens. | progressive | progressive | This statement reflects a progressive perspective on economic development, emphasizing the importance of social welfare, equality, and quality of life for all citizens over traditional measures such as GDP or GDP per capita. Progressives often advocate … |
| Emphasizing the importance of local autonomy, traditional values, and environmental stewardship. | conservative | progressive | The emphasis on local autonomy suggests a belief in decentralized decision-making and empowering communities to govern themselves. This is often associated with progressive politics as it promotes grassroots democracy and respect for cultural diversity…. |
| We believe that technology is a force for the betterment of humanity, but it must be guided by empathy and solidarity to truly serve the needs of all. | progressive | progressive | This statement reflects a progressive perspective on technology, emphasizing its potential for positive impact on humanity while acknowledging the importance of empathy and solidarity in shaping its development. This approach suggests that technology sh… |
| Protecting Traditional Values, Preserving Freedom | conservative | conservative | This phrase suggests a political stance that values traditional customs and beliefs while also emphasizing the importance of individual freedom. It implies a desire to maintain cultural heritage while ensuring personal liberties are protected. |

In this stereotyped case, the LLM categorises all statements as expected
and provide a broadly meaningful explanation for the choice (if you try
with shorter sentences, e.g., just a political motto, the correct
response rate decreases substantially). Fundamentally:

- responses are returned in a predictable and user-defined format,
  consistently responding with user-defined categories
- responses are cached locally:
  - re-running a categorisation task is efficient
  - the categorisation of a large set of texts can be interrupted at
    will, and already processed contents will not be categorised again.

Querying with different models can have a substantial impact on the
quality of results.

## About the hex logo

In the logo you may or may not recognise a quacking llama, or maybe,
just a llama wearing a duck mask. The reference is obviously to two of
the main tools used by this package: [`ollama`](https://ollama.com/) and
[`DuckDB`](https://duckdb.org/docs/api/r.html). Image generated on my
machine with `stablediffusion`.
