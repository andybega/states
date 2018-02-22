# Package development -----------------------------------------------------
#
#   keep track in news.md
#

library("devtools")
library("pkgdown")

if (!requireNamespace("pkg", quietly = TRUE)) {
  stop("Pkg needed for this function to work. Please install it.",
       call. = FALSE)
}

# Check local
devtools::load_all()
devtools::test()
devtools::document()
devtools::check()
pkgdown::build_site()


# Package release ---------------------------------------------------------

library("devtools")

#   Update NEWS
#
#   Update date and version in DESCRIPTION:
#     [major][minor][patch][dev]
#       - major: not backwards compatible
#       - minor: feature enhancements
#       - patch: fixes bugs
#       - dev (9000): working version

devtools::check()
devtools::build()

build_win(version = "R-release")
build_win(version = "R-devel")

# commit to git for travis
# https://travis-ci.org

#   once emails are in and travis is done:
#
#   Update cran-comments.md

R.Version()$version.string

devtools::release()

# update local install
desc <- readLines("DESCRIPTION")
vers <- desc[grep("Version", desc)]
vers <- stringr::str_extract(vers, "[0-9\\.]+")
devtools::install_url(paste0("file://", getwd(), "/../states_", vers, ".tar.gz"))


# Notes -------------------------------------------------------------------

# - change state_panel to recognize date resolutions, e.g. "2017-05" implies monthly data
# - use broad matching, i.e. for "2017" match any state that existed at any point
# in 2017, more specific matching can in most cases be done by specifying more predise dates, e.g. "2017-12-31" to match at end of year
# - year: first, last are unambiguous, no issues
# - day: no ambiguity
# - month: first and middle are clear, last day of month is not
# - other formats? week, quarter?
#
#   More flexible handline of date inputs:
#
#   - state_panel(2011, 2013) shoud make annual data, include South Sudan
# - state_panel("2011-07", "2012-07") should make monthly data, include SS
# - state_panel("2011-07", "2012-07", last_day = TRUE) monthly data, no SS
# - state_panel("2011", "2012", last_day = TRUE) monthly data 2011-01:2012-12
# - state_panel("2011-07", "2012-07", last_day = TRUE) monthly data 2011-07:2012-07
# - state_panel("2011-07-01", "2012-07-01", last_day = TRUE) monthly data, 2011-07:2012-07, no SS
#
# Weekly data...ISO standard weeks like "2017-W01"? Changing day of week is trivial with add or subtract days relative to Thursday.
#
# Separate out `date` and `datestr` in state_panel.
#
# More:
#
#   - add something that gives overview of G&W/COW differences for when coding between by hand
#
# Later:
#
#   - spatial lagging
# - https://aledemogr.wordpress.com/2015/10/09/creating-neighborhood-matrices-for-spatial-polygons/
#   - http://www.people.fas.harvard.edu/~zhukov/Spatial3.pdf
# - dyadic data
#
#
#   Notes from state_panel data revision
#
#' Parsing of the \code{partial} option depends on the time resolution.
#' \itemize{
#'   \item{\code{"first"} and \code{"last"} are the first and last days of the
#'         time period, e.g. February 28th, March 31st, etc.}
#'   \item{\code{"middle"} is yyyy-07-02, yyyy-mm-16, and Wednesdays for weekly.}
#' }
#'
#' The period or time resolution for the time dimensions of the output panel data
#' can be controlled in one of two days. First, if the from and to arguments
#' have valid R dates or strings in the format "YYYY-MM-DD", the period argument
#' is used to set the time period (and must not be NULL). Alternatively,
#' the from and to arguments can be used directly to specify the time period
#' desired by using one of the recognized date string representations listed
#' below.
#'
#' The function recognizes the following date string formats:
#' \itemize{
#'   \item{YYYY: years, i.e. annual data.}
#'   \item{YYYY-MM: year-month period, i.e. monthly data.}
#'   \item{YYYY-QN: quarters, where N ranges from 1 to 4.}
#'   \item{YYYY-WNN: standard ISO weeks, where "NN" ranges from "01" to "52" or "53" depending on the year.}
#' }
#
#    use cases:
#
# 1.  yyyy,       by = NULL,   partial = NULL    no by, infer annual, no partial, error
# 2.  yyyy,       by = NULL,   partial = "first" no by, infer annual, first
# 3.  yyyy,       by = "year", partial = NULL    annual, fmt is annual, no partial, error
# 4.  yyyy,       by = "year", partial = "first" annual, fmt is annual, first
# 5.  yyyy-mm,    by = NULL,   partial = NULL    no by, infer month, no partial, error
# 6.  yyyy-mm,    by = NULL,   partial = "first"
# 7.  yyyy-mm,    by = "year", partial = NULL
# 8.  yyyy-mm,    by = "year", partial = "first"
# 9.  yyyy-mm-dd, by = NULL,   partial = NULL
# 10. yyyy-mm-dd, by = NULL,   partial = "first"
# 11. yyyy-mm-dd, by = "year", partial = NULL
# 12. yyyy-mm-dd, by = "year", partial = "first"
#
# flow:
# 1. Check date format
# 2. Is there by?
#   3. YES: Is there partial?
#     4. YES: Does date format match by?
#       5. YES: make data
#       6. NO: error
#     7. NO:

