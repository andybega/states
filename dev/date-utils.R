#' #'
#' #' Generate a sequence of periods
#' #'
#' #' @param from Starting date, character like YYYY-MM-DD or class Date
#' #' @param to End date for sequence, character like YYYY-MM-DD or class Date
#' #' @param period The length of the periods in the sequence, supported are year,
#' #'   quarter, month, week, day.
#' #' @param position The position of the output date in the time period,
#' #'   supported are "first", "middle", "last", or "identity".
#' #'
#' #' @details
#' #' The output are valid dates. Which specific month and day are assigned to a
#' #' given time period is resolved like this:
#' #' \itemize{
#' #'   \item{year: "first" is 1 January, "middle" is 30 June, "last" is 31 December}
#' #'   \item{quarter: "first" is first day of the first month in quarter, "middle" is 15th of the second month in quarter, "last" is last day of last month in quarter.}
#' #'   \item{month: "first" is first day in month, "middle" is the 15th, and "last" is the last day of the month, i.e. 31st for January, 28th or 29th for February, etc.}
#' #'   \item{week: weekdays indexed by Thursday, which corresponds to "middle", i.e. "first" and "last" correspond to Mondays and Sundays.}
#' #' }
#' #' If position is set to "identity", the month and day of the input from date
#' #' determine how date placements within a time period are resolved.
#' #'
#' #' @examples
#' #' seq_date("2015-01-01", "2017-01-01", period = "year", position = "first")
#' #'
#' #' @import lubridate
#'
#' seq_period <- function(from, to, period, position) {
#'   if (!period %in% c("year", "quarter", "month", "week", "day")) {
#'     stop(sprintf("Wrong period argument '%s', valid options are: %s",
#'                  period,
#'                  paste0(c("year", "quarter", "month", "week", "day"), collapse = ", ")))
#'   }
#'   if (!position %in% c("first", "middle", "last", "identity")) {
#'     stop(sprintf("Wrong position argument '%s', valid options are: %s",
#'                  position,
#'                  paste0(c("first", "middle", "last", "identity"))))
#'   }
#'   if (lubridate::day(from) > 28 & period =="month") {
#'     stop(sprintf(
#'       "Ambiguous day in 'from = %s', day should be less than 29; if you want last day of month use 'position = \"last\"'",
#'       as.character(from)))
#'   }
#'
#'   out <- seq(as.Date(from), as.Date(to), by = period)
#'   if (period=="year") {
#'     if (position=="first") {
#'       month(out) <- 1
#'       day(out)   <- 1
#'     } else if (position=="middle") {
#'       month(out) <- 6
#'       day(out)   <- 30
#'     } else if (position=="last") {
#'       month(out) <- 12
#'       day(out)   <- 31
#'     } else if (position=="identity") {
#'       out <- out
#'     } else {
#'       stop("Internal error, position")
#'     }
#'   }
#'   if (period=="month") {
#'     if (position=="first") {
#'       day(out)   <- 1
#'     } else if (position=="middle") {
#'       day(out)   <- 15
#'     } else if (position=="last") {
#'       out <- out %m+% months(1)
#'       day(out) <- 1
#'       out <- out - 1
#'     } else if (position=="identity") {
#'       out <- out
#'     } else {
#'       stop("Internal error, position")
#'     }
#'   }
#'   if (period=="quarter") {
#'     stop("this is complicated")
#'     if (position=="first") {
#'       month(out) <- quarter(out)*3 - 2
#'       day(out)   <- 1
#'     } else if (position=="middle") {
#'       month(out) <- quarter(out)*3 - 1
#'       day(out)   <- 15
#'     } else if (position=="last") {
#'       month(out) <- quarter(out)*3 + 1
#'       day(out) <- 1
#'       out <- out - 1
#'     } else if (position=="identity") {
#'       out <- out
#'     }
#'   }
#'   if (period=="week") {
#'     stop("this is complicated")
#'     if (position=="first") {
#'       # using Monday as first day of week, per ISO standard
#'       wday(out) <- 2
#'     } else if (position=="middle") {
#'       wday(out) <- 5
#'     } else if (position=="last") {
#'       # since lubridate starts weeks at Sunday, this shifts all weeks to previous
#'       # week for ISO weeks; fix by adding 7 days
#'       wday(out) <- 1
#'       out <- out + 7
#'     } else if (position=="identity") {
#'       out <- out
#'     }
#'   }
#'   out
#' }
#'
#' #' Convert dates to normalized dates given a period
#' #'
#' #'
#' normalize_date <- function(x, period = NULL) {
#'   NULL
#' }
#'
#' datestr2date <- function(x, position = "middle") {
#'   NULL
#' }
#'
#' date2datestr <- function(x, period = NULL) {
#'   if (period=="year") {
#'     x <- lubridate::year(x)
#'   } else if (to=="quarter") {
#'     x <- sprintf("%s-Q%s", lubridate::year(x), lubridate::quarter(x))
#'   } else if (to=="month") {
#'     x <- format(x, "%Y-%m")
#'   } else if (to=="week") {
#'     x <- sprintf("%s-W%02s", lubridate::year(x), lubridate::isoweek(x))
#'   } else {
#'     stop("Unrecognized period format")
#'   }
#'   x
#' }
#'
#' #' Detect date format
#' #'
#' #' @param x Input string or integer
#' #'
#' detect_date_format <- function(x) {
#'   x <- as.character(x)
#'   if (grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x)) {
#'     date_format <- "ymd"
#'   } else if (grepl("^[0-9]{4}-[0-9]{2}$", x)) {
#'     date_format <- "ym"
#'   } else if (grepl("^[0-9]{4}$", x)) {
#'     date_format <- "y"
#'   } else {
#'     stop(sprintf("Could not parse date format for %s", x))
#'   }
#'   date_format
#' }
#'
#'
#'
