ql_categorise <- function(prompt,
                          system = "You are a helpful assistant.",
                          host = "http://localhost:11434",
                          model = "llama3.2",
                          endpoint = "generate",
                          temperature = 0,
                          seed = 0) {
  req <- httr2::request(host) |>
    httr2::req_url_path(endpoint) |>
    httr2::req_headers("Content-Type" = "application/json") |>
    httr2::req_body_json(
      list(
        model = model,
        prompt = prompt,
        format = "json",
        truncate = FALSE,
        stream = FALSE,
        keep_alive = "10s",
        raw = FALSE,
        options = list(
          seed = seed,
          temperature = temperature
        ),
        system = system
      )
    ) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- req |>
    httr2::req_perform()

  resp_l <- resp |>
    httr2::resp_body_json()

  json_output_l <- resp_l |>
    purrr::pluck("response") |>
    stringr::str_squish() |>
    yyjsonr::read_json_str()

  if (length(json_output_l) == 0) {
    extracted_v <- NA_character_
  } else {
    extracted_v <- json_output_l[[1]]

    if (length(extracted_v) == 0) {
      extracted_v <- NA_character_
    }
  }

  output_df <- tibble::tibble(
    #  doc_id = item[["doc_id"]],
    response = extracted_v,
    total_duration = resp_l |>
      purrr::pluck("total_duration"),
    model = resp_l |>
      purrr::pluck("model"),
    seed = seed,
    temperature = temperature
  )

  output_df
}
