library("quackingllama")

resp_df <- ql_prompt(prompt = "haiku") |>
  ql_generate()

ql_na_response_df <- resp_df |>
  dplyr::slice(0) |>
  dplyr::add_row(response = NA_character_)

usethis::use_data(ql_na_response_df, overwrite = TRUE)
