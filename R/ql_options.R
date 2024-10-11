#' Set options for the local database
#'
#' @param db_name Defaults to `quackingllama`. Name given to the local database
#'   file. Useful for differentiating among different approaches or projects
#'   when storing multiple database files in the same folder.
#' @param db_type Defaults to `DuckDB`.
#' @param db_folder Defaults to `.`, i.e., to the current working directory.
#'
#' @family database
#'
#' @return Nothing, used for its side effects..
#' @export
#'
#' @examples
#' ql_set_db_options(db_name = "testing_ground")
ql_set_db_options <- function(db_name = "quackingllama",
                              db_type = "DuckDB",
                              db_folder = ".") {
  if (is.null(db_folder) == FALSE) {
    Sys.setenv(quackingllama_db_folder = db_folder)
  }

  ql_enable_db(db_type = db_type)
}




#' Enable storing data in a database for the current session
#'
#' @inheritParams ql_set_db_options
#'
#' @family database
#'
#' @return Nothing, used for its side effects.
#' @export
#' @examples
#' ql_enable_db()
ql_enable_db <- function(db_type = "DuckDB") {
  Sys.setenv(quackingllama_db = TRUE)
  Sys.setenv(quackingllama_db_type = db_type)
}


#' Disable caching for the current session
#'
#' @family database
#'
#' @return Nothing, used for its side effects.
#' @export
#' @examples
#' ql_disable_db()
ql_disable_db <- function() {
  Sys.setenv(quackingllama_db = FALSE)
}
