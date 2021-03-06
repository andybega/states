% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/misc.R
\name{prettyc}
\alias{prettyc}
\title{Shorten country names}
\usage{
prettyc(x)
}
\arguments{
\item{x}{(\code{\link[=character]{character()}})\cr
Country names, e.g. from \code{\link[=country_names]{country_names()}}.}
}
\description{
Shorten country names
}
\examples{
cn <- c(
  "Macedonia, the former Yugoslav Republic of",
  "Congo, the Democratic Republic of the",
  "Tanzania, United Republic of")
prettyc(cn)

}
