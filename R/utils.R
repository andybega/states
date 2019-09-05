#' Parse date
#'
#' Try to parse input as a date
#'
#' @param x a integer or character vector, see examples
#'
#' @examples
#' parse_date(2006)
#' parse_date("2006")
#' parse_date("2006-06")
#' parse_date("2006-06-01")
#' parse_date(as.Date("2006-06-01"))
#'
#' @export
parse_date <- function(x) {

  if (methods::is(x, "Date")) {
    return(x)
  }

  period <- sapply(x, id_period)
  if (length(unique(period)) > 1) {
    stop(sprintf("Found multiple implied time periods (%s)",
                 paste(period, collapse = ", ")))
  }
  period <- unique(period)

  if (period=="year") {
    return(as.Date(sprintf("%s-01-01", x)))
  }

  if (period=="month") {
    return(as.Date(sprintf("%s-01", x), format = "%Y-%m-%d"))
  }

  if (period=="day") {
    return(as.Date(x, format = "%Y-%m-%d"))
  }

  err_msg <- sprintf("Could not identify date for ['%s']", paste0(x, collapse = "', '"))
  stop(err_msg)

}


#' ID time period
#'
#' Try to ID the time period implied by input format
#'
#' @keywords internal
id_period <- function(x) {
  stopifnot(length(x)==1)
  if (grepl("^[0-9]{4}$", x)) return("year")
  if (grepl("^[0-9]{4}-[0-9]{1,2}$", x)) return("month")
  if (grepl("^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$", x)) return("day")
  stop("Could not identify implied period")
}
