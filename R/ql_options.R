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

#' Retrieve
#'
#' @param options Available options that
#'
#' @return A list with the selected options.
#' @export
#'
#' @examples
#' ql_get_db_options()
#'
#' ## Retrieve only selected option
#' ql_get_db_options("db_type")
ql_get_db_options <- function(options = c(
                                "db",
                                "db_type",
                                "db_folder",
                                "db_name"
                              )) {
  ql_db_options_list <- list(
    db = as.logical(Sys.getenv("quackingllama_db", unset = FALSE)),
    db_type = as.character(Sys.getenv("quackingllama_db_type", unset = "DuckDB")),
    db_folder = fs::path(Sys.getenv("quackingllama_db_folder", unset = ".")),
    db_name = as.character(Sys.getenv("quackingllama_db_name", unset = "quackingllama"))
  )

  ql_db_options_list[options]
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

#' Set basic options for the current session.
#'
#' @param model
#' @param host
#' @param system
#' @param temperature
#' @param seed
#'
#' @return
#' @export
#'
#' @examples
ql_set_options <- function(model = NULL,
                           host = NULL,
                           system = NULL,
                           temperature = NULL,
                           seed = NULL) {
  if (!is.null(model)) {
    Sys.setenv(quackingllama_model = model)
  }

  if (!is.null(host)) {
    Sys.setenv(quackingllama_host = host)
  }

  if (!is.null(system)) {
    Sys.setenv(quackingllama_system = system)
  }

  if (!is.null(temperature)) {
    Sys.setenv(quackingllama_temperature = temperature)
  }

  if (!is.null(seed)) {
    Sys.setenv(quackingllama_seed = seed)
  }
}

#' Get options
#'
#' @param options A character vector with all available options
#'
#' @return A list with all available options (or those selections with
#'   `options`)
#' @export
#'
#' @examples
#' ql_get_options()
ql_get_options <- function(options = c(
                             "model",
                             "host",
                             "system",
                             "temperature",
                             "seed"
                           )) {
  ql_options_list <- list(
    model = as.logical(Sys.getenv("quackingllama_model", unset = "llama3.2")),
    host = as.character(Sys.getenv("quackingllama_host", unset = "http://localhost:11434")),
    system = as.character(Sys.getenv("quackingllama_system", unset = "You are a helpful assistant.")),
    temperature = as.integer(Sys.getenv("quackingllama_temperature", unset = 0)),
    seed = as.integer(Sys.getenv("quackingllama_db_name", unset = sample.int(n = .Machine$integer.max, size = 1)))
  )

  ql_options_list[options]
}
