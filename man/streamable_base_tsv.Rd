% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/streamable_table.R
\name{streamable_base_tsv}
\alias{streamable_base_tsv}
\title{streamable tsv using base R functions}
\usage{
streamable_base_tsv()
}
\value{
a \code{streamable_table} object (S3)
}
\description{
streamable tsv using base R functions
}
\details{
Follows the tab-separate-values standard using \code{\link[utils:read.table]{utils::read.table()}},
see IANA specification at:
\url{https://www.iana.org/assignments/media-types/text/tab-separated-values}
}
\seealso{
\code{\link[utils:read.table]{utils::read.table()}}, \code{\link[utils:write.table]{utils::write.table()}}
}
