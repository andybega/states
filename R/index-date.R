
#' Index date
#'
#' Find the first day of the time intervals in which a set of dates fall
#'
#' @param x a [base::Date()] vector
#' @param period a time period, e.g. "year" or "month"
#'
#' @keywords internal
index_date <- function(x, period) {

  x <- as.Date(x)

  if (period=="day") {
    return(x)
  }

  if (period=="year") {
    return(as.Date(sprintf("%s-01-01", substr(as.character(x), 1, 4))))
  }

  if (period=="month") {
    return(as.Date(sprintf("%s-01", substr(as.character(x), 1, 7))))
  }

  stop(sprintf("Method for period '%s' not implemented", period))
}
