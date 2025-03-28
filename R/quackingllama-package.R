#' @importFrom rlang .data
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
#' @importFrom rlang .env
## usethis namespace: end
NULL

# add reference to packages only suggested by `httr2`, but actually needed, see:
# https://r-pkgs.org/dependencies-in-practice.html#how-to-not-use-a-package-in-imports
httr2_suggested_imports <- function() {
  httpuv::encodeURI("")
  jsonlite::base64_enc("")
}
