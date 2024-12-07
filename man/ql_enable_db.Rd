% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ql_options.R
\name{ql_enable_db}
\alias{ql_enable_db}
\title{Enable storing data in a database for the current session}
\usage{
ql_enable_db(db_type = "DuckDB")
}
\arguments{
\item{db_type}{Defaults to \code{DuckDB}.}
}
\value{
Nothing, used for its side effects.
}
\description{
Enable storing data in a database for the current session
}
\examples{
ql_enable_db()
}
\seealso{
Other database: 
\code{\link{ql_disable_db}()},
\code{\link{ql_set_db_options}()}
}
\concept{database}
