#' Read image in order to pass it to multimodal models
#'
#' @param path Path to image file.
#'
#' @returns A list object of character vectors of base 64 encoded images.
#' @export
#'
#' @examples
#' if (interactive) {
#'   library("quackingllama")
#'
#'   img_path <- fs::file_temp(ext = "png")
#'
#'   download.file(
#'     url = "https://ollama.com/public/ollama.png",
#'     destfile = img_path
#'   )
#'
#'   resp_df <- ql_prompt(
#'     prompt = "what is this?",
#'     images = img_path,
#'     model = "llama3.2-vision"
#'   ) |>
#'     ql_generate()
#'
#'   resp_df
#'
#'   resp_df$response
#' }
ql_read_images <- function(path) {
  if (is.null(path)) {
    list(NA_character_)
  } else {
    purrr::map(
      .x = path,
      .f = \(current_path) {
        base64enc::base64encode(current_path)
      }
    )
  }
}
