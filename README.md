
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
#> tibble [1 × 21] (S3: tbl_df/tbl/data.frame)
#>  $ response            : chr "Meet Aurora \"Rory\" Thompson, the charismatic and progressive leader of the coastal nation of Azura. A former "| __truncated__
#>  $ prompt              : chr "Describe an imaginary political leader in less than 100 words."
#>  $ thinking            : chr NA
#>  $ created_at          : chr "2025-07-19T14:40:25.179215418Z"
#>  $ done                : logi TRUE
#>  $ done_reason         : chr "stop"
#>  $ total_duration      : num 1.04e+10
#>  $ load_duration       : num 7.43e+09
#>  $ prompt_eval_count   : num 43
#>  $ prompt_eval_duration: num 2.59e+08
#>  $ eval_count          : num 118
#>  $ eval_duration       : num 2.72e+09
#>  $ timeout             : num 300
#>  $ keep_alive          : chr "5m"
#>  $ think               : logi FALSE
#>  $ model               : chr "llama3.2"
#>  $ system              : chr "You are a helpful assistant."
#>  $ format              : chr ""
#>  $ seed                : num 0
#>  $ temperature         : num 0
#>  $ hash                : chr "1b383c4d98978dfd1805743b597fd361"
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
#> [1] "Aurora Wynter is a charismatic and visionary leader who has captivated the hearts of her people with her unwavering commitment to justice, equality, and environmental sustainability. Born in the coastal city of Newhaven, Aurora grew up surrounded by the beauty and fragility of the ocean, which instilled in her a deep love for the natural world and a fierce determination to protect it."
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
#> [1] "Aurora Wynter is a charismatic and visionary leader who has captivated the hearts of her people. Born into a family of modest means, she rose to prominence as a grassroots activist, fighting for social justice and equality. Her unwavering commitment to these values has earned her the respect and admiration of her constituents."
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
#> [1] "Pizza in the night\nMozzarella dreams so sweet\nTummy's happy song"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Socks disappear too\n Lost my sole mates in the wash\nLonely foot remains"
ql_prompt(prompt = "A reasonably funny haiku", temperature = 1) |>
  ql_generate() |>
  dplyr::pull(response)
#> [1] "Pizza in my face\nMelty cheese and saucey shame\nTummy's guilty grin"
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
#> [1] "This haiku is humorous because it takes the common experience of passing gas and applies it to an unexpected situation - being in outer space. The idea that someone could let out a fart while floating in zero gravity, causing their own spaceship to drift away, is absurd and comical. It's also a bit of a commentary on how even in the most unlikely situations, human bodily functions can still be a source of embarrassment."
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
#>    `party name`              `political leaning` `political statement`          
#>    <chr>                     <chr>               <chr>                          
#>  1 The Luminari Party        progressive         "Embracing a global citizenry …
#>  2 Virtus                    conservative        "austrian  economics in americ…
#>  3 The New Horizon Party     progressive         "The New Horizon Party advocat…
#>  4 Libertarian Progressives  conservative        "Balancing Tradition with Inno…
#>  5 Luminaria                 progressive         "At Luminaria, we believe that…
#>  6 Libertas Novi             conservative        "We believe that the United St…
#>  7 Eudaimonia                progressive         "We believe that the greatest …
#>  8 The Terra Vita Party      conservative        "Emphasizing the importance of…
#>  9 Eunoia Party              progressive         "The Eunoia Party is committed…
#> 10 The New Order Party (NOP) conservative        "Protecting Traditional Values…
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
| Embracing a global citizenry through the universal basic income, sustainable development and intergenerational justice. | progressive | progressive | This statement advocates for three key progressive policies: Universal Basic Income (UBI), Sustainable Development, and Intergenerational Justice. The Universal Basic Income is a policy where every citizen receives a set amount of money regularly, regar… |
| austrian economics in american governance | conservative | conservative | Austrian Economics, which emphasizes the importance of individual action and market processes, has had an influence on American governance, particularly among conservative political circles. The Austrian School’s key principles, such as subjectivism (th… |
| The New Horizon Party advocates for a future where technology is used to create a sustainable, equitable, and just society for all. | progressive | progressive | The New Horizon Party appears to be a progressive political party that emphasizes the use of technology to achieve a sustainable, equitable, and just society. This suggests they are forward-thinking, prioritizing innovation and technological advancement… |
| Balancing Tradition with Innovation | conservative | progressive | Balancing tradition with innovation means finding a harmonious blend of respecting and preserving the values, customs, and practices of the past while embracing new ideas, technologies, and methods that can improve and advance society. This approach req… |
| At Luminaria, we believe that the collective well-being of our society is inextricably linked to the well-being of its most vulnerable members. We advocate for a world where every individual has access to quality healthcare, education, and economic opportunities, regardless of their background or circumstances. | progressive | progressive | Luminaria’s mission statement emphasizes the importance of social justice and equality for all individuals, particularly those who are most vulnerable in society. They advocate for policies that ensure access to essential resources such as healthcare, e… |
| We believe that the United States is at its strongest when it maintains a strong sense of self-reliance, limited government intervention, and unwavering commitment to traditional values. | conservative | conservative | The statement suggests a conservative political ideology that emphasizes individualism, minimal government interference, and adherence to traditional values. This perspective often advocates for self-reliance, which means relying on one’s own efforts ra… |
| We believe that the greatest wealth of any nation is not measured by its GDP or GDP per capita, but rather by the well-being and flourishing of all its citizens. | progressive | progressive | This statement reflects a progressive perspective on economic development, emphasizing that a nation’s true wealth lies not in material wealth or financial indicators like GDP, but rather in the well-being and flourishing of its citizens. This perspecti… |
| Emphasizing the importance of local autonomy, traditional values, and environmental stewardship. | conservative | progressive | This individual or group prioritizes the empowerment of local communities, preservation of cultural traditions, and sustainable management of natural resources. They advocate for policies that allow regions to govern themselves while maintaining a stron… |
| The Eunoia Party is committed to ‘Designing a Brighter Tomorrow for All’ by prioritizing human well-being, social justice, and ecological sustainability. | progressive | progressive | The Eunoia Party appears to be a progressive political party, as it emphasizes human well-being, social justice, and ecological sustainability. These are key issues that progressive parties often prioritize, with the goal of creating a more equitable an… |
| Protecting Traditional Values, Preserving Freedom | conservative | conservative | This phrase suggests a political stance that values traditional customs and beliefs while also emphasizing the importance of individual freedom. It implies a balance between preserving cultural heritage and upholding personal liberties, often associated… |

In this stereotyped case, the LLM categorises most statements as
expected and provide a broadly meaningful explanation for the choice (if
you try with shorter sentences, e.g., just a political motto, the
correct response rate decreases substantially). Fundamentally:

- responses are returned in a predictable and user-defined format,
  consistently responding with user-defined categories
- responses are cached locally:
  - re-running a categorisation task is efficient
  - the categorisation of a large set of texts can be interrupted at
    will, and already processed contents will not be categorised again.

Querying with different models can have a substantial impact on the
quality of results.

## Pass images to the model

You can pass images and have multimodal models such as
e.g. “llama3.2-vision” or (the considerably smaller) “llava-phi3”
consider them in their response. Just pass the path of the relevant
image to `ql_prompt()`. For example, if we ask to describe the logo of
this package, we get the following reponse:

``` r
library("quackingllama")

img_path <- fs::path(
  system.file(package = "quackingllama"),
  "help",
  "figures",
  "logo.png"
)

resp_df <- ql_prompt(
  prompt = "what is this?",
  images = img_path,
  model = "llama3.2-vision"
) |>
  ql_generate()


cat(">", resp_df$response)
```

> This appears to be a digital illustration of a bird’s head, possibly a
> duck or goose, with a bright pink hexagon border around it. The image
> is likely a graphic or icon used for decorative or illustrative
> purposes.

``` r
resp_df <- ql_prompt(
  prompt = "what is this?",
  images = img_path,
  model = "llava-phi3"
) |>
  ql_generate()


cat(">", resp_df$response)
#> > The image features a close-up of an alpaca's face, which is set against a black background. The alpaca has a yellow and gray mask on its face, with the eyes closed in what appears to be sleep or rest. The mask covers the alpaca's mouth and nose, giving it a unique appearance. The image is framed by a pink border, adding a pop of color to the overall composition. The alpaca seems calm and at ease despite the unusual accessory.
```

## Thinking models

In May 2025, Ollama started supporting “thinking” models ([more details
in the post announcing the feature](https://ollama.com/blog/thinking)).
Pay attention to the fact that not all reasoning models available via
Ollama actually support thinking mode; as of July 2025, only three
models were effectively supported (`deepseek-r1`, `qwen3`, and
`magistral`). An [up-to-date list should be available on Ollama’s
website](https://ollama.com/search?c=thinking).

When thinking mode is enabled, the LLM goes through an iterative
“thinking” process before providing its answer. The “thinking” process
is expressed in plain English and can be seen along with the response.
See the following example:

``` r
strawberry_t_df <- ql_prompt(
  prompt = "How many r are there in strawberry? Provide a concise answer.",
  model = "deepseek-r1:1.5b",
  think = TRUE) |>
  ql_generate()
```

Here’s the thinking:

``` r

cat(">", strawberry_t_df$thinking |> stringr::str_replace_all(pattern = stringr::fixed("\n"), replacement = "\n > ")) 
```

> Okay, so I need to figure out how many ’r’s are in the word
> “strawberry.” Hmm, let me start by writing down the word: S T R A W B
> E R R Y.
>
> Wait, that doesn’t seem right. Let me check again. The spelling is
> S-T-R-A-W-B-E-R-R-Y. So I think I missed an ‘r’ somewhere. Let me go
> through each letter one by one to make sure I don’t miss any.
>
> 1.  S – nope.
> 2.  T – nope.
> 3.  R – yes, that’s the first ‘r’.
> 4.  A – nope.
> 5.  W – nope.
> 6.  B – nope.
> 7.  E – nope.
> 8.  R – second ‘r’.
> 9.  R – third ‘r’.
> 10. Y – nope.
>
> Wait a minute, I think I might have missed an ‘R’ at the end of
> “berry.” Let me count again: S T R A W B E R R Y. So after B comes E,
> then R (that’s one), then another R (two), and finally Y. So that
> makes three ’r’s in total.
>
> But wait, I’m not sure if the word is spelled correctly. Maybe it’s
> “strawberry” without an extra ‘R’ at the end? Let me check a
> dictionary or something to confirm. Oh, no, it does have two more ’R’s
> after E and before Y. So that makes three ’r’s in total.
>
> I think I was overcomplicating it by thinking about the word
> “strawberry” as if it were spelled without those extra letters. But
> actually, it is spelled with two more ’R’s. So the answer should be
> three ’r’s.

And here is the response:

``` r
cat(">", strawberry_t_df$response)
```

> There are three ’r’s in the word “strawberry.”

## About context windows and time-outs

`ollama` is great in enabling easy local deployment of local LLMs, but
comes with some embedded defaults that may come with unintended
consequences.

### About the context window

If you look at the model page of one of the models available from
Ollama’s website, you may well notice that some of these come with very
large context windows. For example,
[`gemma3`](https://ollama.com/library/gemma3) boasts a “128K context
window”, big enough to include book-length inputs. You may well expect
that, by default, this context window is fully available to you. You
would, however, be mistaken: no matter the model’s capabilities, Ollama
truncates the input at 2048 tokens: as a user, you would notice it only
if you looked at the `ollama serve` logs, or because you notice
unsatisfying results, as truncation happens in a way that is mostly
invisible to the client. This is a known issue with Ollama, and until
this is approached more sensibly by Ollama, the user should take core of
this limitation themselves (`quackingllama` will likely include a
dedicated warning in future versions). The easiest workaround is to
re-create a new model with a larger context window: it’s a matter of a
few seconds, following the [instructions reported in the relevant issue
on
Ollama](https://github.com/ollama/ollama/issues/8099#issuecomment-2543316682).

Basically, from the command line you do something like this:

    $ ollama run gemma3
    >>> /set parameter num_ctx 65536
    Set parameter 'num_ctx' to '65536'
    >>> /save gemma3-64k
    Created new model 'gemma3-64k'
    >>> /bye

And in a matter of seconds you will get a `gemma3` model with a 64k
context window, which you’ll be able to use by choosing `gemma3-64k` as
model.

### About `timeout` and `keep_alive`

Congratulations, now you can enjoy bigger context windows. This is all
nice, but this makes it also more likely that you are going to stumble
into time-out issues, as processing lengthy prompts can take many
minutes.

There are two parameters that determine how long `quackingllama` will
wait for a response from `ollama` before throwing an error.

- one is `ollama`’s `keep_alive` argument, that basically tells how long
  the model should remain in memory after it is called. By default, this
  is “5m” for five minutes. If the model doesn’t get a response in time,
  it throws an error.
- one is `httr2`’s `timeout` argument, that expresses how long the
  client should be waiting for a response. This defaults to “300”, as it
  is expressed in seconds, and corresponds to 5 minutes.

The combined effect of these two arguments may not be exactly as you
expect (a 5 minute `keep_alive` may actually let the model run for 10
minutes, if your `timeout` argument is big enough), but either way, be
mindful and if you do expect lengthy response times, do set both values
to an adequately high value.

On the other hand, if you know you have short prompts and expect quick
responses, the defaults are more efficient, and will just move on sooner
if the model is stuck for whatever reason.

## About the hex logo

In the logo you may or may not recognise a quacking llama, or maybe,
just a llama wearing a duck mask. The reference is obviously to two of
the main tools used by this package: [`ollama`](https://ollama.com/) and
[`DuckDB`](https://duckdb.org/docs/api/r.html). Image generated on my
machine with `stablediffusion`.
