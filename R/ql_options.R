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
#' @return Nothing, used for its side effects.
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
ql_get_db_options <-
  function(
      options = c(
        "db",
        "db_type",
        "db_folder",
        "db_name"
      )) {
    ql_db_options_list <- list(
      db = as.logical(Sys.getenv("quackingllama_db",
        unset = TRUE
      )),
      db_type = as.character(Sys.getenv("quackingllama_db_type",
        unset = "DuckDB"
      )),
      db_folder = fs::path(Sys.getenv("quackingllama_db_folder",
        unset = "."
      )),
      db_name = as.character(Sys.getenv("quackingllama_db_name",
        unset = "quackingllama"
      ))
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
#' @param model The name of the model, e.g. `llama3.2` or `phi3.5:3.8b`. Run
#'   `ollama list` from the command line to see a list of locally available
#'   models.
#' @param host The address where the Ollama API can be reached, e.g.
#'   `http://localhost:11434` for locally deployed Ollama.
#' @param system System message to pass to the model. See official documentation
#'   for details. For example: "You are a helpful assistant."
#' @param temperature Numeric value comprised between 0 and 1 passed to the
#'   model. When set to 0 and with the same seed, the response to the same
#'   prompt is always exactly the same. When closer to one, the response is more
#'   variable and creative. Use 0 for consistent responses. Setting this to 0.7
#'   is a common choice for creative or interactive tasks.
#' @param seed An integer. When temperature is set to 0 and the seed is
#'   constant, the model consistently returns the same response to the same
#'   prompt.
#' @param keep_alive Defaults to "5m". Controls controls how long the model will
#'   stay loaded into memory following the request.
#'
#' @return Nothing, used for its side effects. Options can be retrieved with
#'   `ql_get_db_options()`
#' @export
#'
#' @examples
#'
#' ql_set_options(
#'   model = "llama3.2",
#'   host = "http://localhost:11434",
#'   system = "You are a helpful assistant.",
#'   temperature = 0,
#'   seed = 42
#' )
#'
#' ql_get_options()
#'
ql_set_options <- function(system = NULL,
                           model = NULL,
                           host = NULL,
                           temperature = NULL,
                           seed = NULL,
                           keep_alive = NULL) {
  if (!is.null(system)) {
    Sys.setenv(quackingllama_system = system)
  }

  if (!is.null(model)) {
    Sys.setenv(quackingllama_model = model)
  }

  if (!is.null(host)) {
    Sys.setenv(quackingllama_host = host)
  }

  if (!is.null(temperature)) {
    Sys.setenv(quackingllama_temperature = temperature)
  }

  if (!is.null(seed)) {
    Sys.setenv(quackingllama_seed = seed)
  }

  if (!is.null(keep_alive)) {
    Sys.setenv(quackingllama_keep_alive = keep_alive)
  }
}

#' Get options
#'
#' @param options A character vector used to filter which options should
#'   effectively be returned. Defaults to all available.
#'
#' @return A list with all available options (or those selected with
#'   `options`)
#' @export
#'
#' @examples
#'
#'
#' ql_set_options(
#'   model = "llama3.2",
#'   host = "http://localhost:11434",
#'   system = "You are a helpful assistant.",
#'   temperature = 0,
#'   seed = 42,
#'   keep_alive = "5m"
#' )
#'
#' ql_get_options()
ql_get_options <- function(
    options = c(
      "system",
      "model",
      "host",
      "temperature",
      "seed",
      "keep_alive"
    ),
    system = NULL,
    model = NULL,
    host = NULL,
    temperature = NULL,
    seed = NULL,
    keep_alive = NULL) {
  ql_options_list <-
    list(
      system = as.character(
        system %||%
          Sys.getenv("quackingllama_system",
            unset = "You are a helpful assistant."
          )
      ),
      model = as.character(
        model %||%
          Sys.getenv("quackingllama_model",
            unset = "llama3.2"
          )
      ),
      host = as.character(
        host %||%
          Sys.getenv("quackingllama_host",
            unset = "http://localhost:11434"
          )
      ),
      temperature = as.integer(
        temperature %||%
          Sys.getenv("quackingllama_temperature",
            unset = 0
          )
      ),
      seed = as.integer(
        seed %||%
          Sys.getenv("quackingllama_db_name",
            unset = sample.int(n = .Machine$integer.max, size = 1)
          )
      ),
      keep_alive = as.character(
        host %||%
          Sys.getenv("quackingllama_keep_alive",
            unset = "5m"
          )
      )
    )

  ql_options_list[options]
}
