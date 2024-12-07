% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ql_get_models.R
\name{ql_get_models}
\alias{ql_get_models}
\title{Get available models}
\usage{
ql_get_models(host = "http://localhost:11434")
}
\arguments{
\item{host}{Defaults to "http://localhost:11434", where locally deployed
Ollama usually responds.}
}
\value{
A data frame (a tibble) with details on all locally available models.
}
\description{
Get available models
}
\examples{
\dontrun{
ql_get_models()
}
}
