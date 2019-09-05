#' Create state panel data
#'
#' Create panel data consisting of independent states in the international system.
#'
#' @param start Beginning date for data, see [parse_date()] for format options.
#' @param end End date for data, see [parse_date()] for format options.
#' @param by Temporal resolution, "year", "month", or "day". If NULL, inferred
#'   from start and end input format, e.g. `start = 2006`` implies `by = "year"`.
#' @param partial Option for how to handle edge cases where a state is independent
#'   for only part of a time period (year, month, etc.). Options include
#'   `"exact"`, `"first"`, `"last"`, and `"any"`. See details.
#' @param useGW Use Gleditsch & Ward statelist or Correlates of War state system
#'     membership list.
#'
#' @details
#' The partial option determines how to handle instances where a country gains
#' or loses independence during a time period specified in the by option:
#'
#' - "exact": the exact date in start is used for filtering
#' - "any": a state-period is included if the state was independent at any point
#'     in that period.
#' - "first": same as "exact" with the first date in a time period, e.g.
#'     "2006-01-01".
#' - "last": last date in a period. For "yearly" data, this is the same as
#'     "exact" with a start date like "YYYY-12-21", but for calendar months
#'     the last date varies, hence the need for this option.
#'
#' @return A [base::data.frame()] with 2 columns for the country code and date
#'   information. The column names and types differ slightly based on the
#'   "useGW" and "by" arguments.
#'
#'   - The first column will be "gwcode" if `useGW = TRUE` (the default), and
#'     "cowcode" otherwise.
#'   - The second column is an integer vector with name "year" for country-year
#'     data (if `by` or the inferred `by` value is "year"), and a [base::Date()]
#'     vector with the name "date" otherwise.
#'
#' @examples
#' # Basic usage with full option set specified:
#' gwlist  <- state_panel("1991-01-01", "2015-01-01", by = "year",
#'                        partial = "any", useGW = TRUE)
#' head(gwlist, 3)
#' cowlist <- state_panel("1991-01-01", "2015-01-01", by = "year",
#'                        partial = "any", useGW = FALSE)
#' head(cowlist, 3)
#'
#' # For yearly data, a proper date is not needed, and by = "year" and
#' # partial = "any" are inferred.
#' gwlist <- state_panel(1990, 1995)
#' sfind(265, list = "GW")
#' 265 %in% gwlist$gwcode
#'
#' # Partials
#' # Focus on South Sudan--is there a record for 2011, first year of indendence?
#' data(gwstates)
#' dplyr::filter(gwstates, gwcode==626)
#'
#' # No 2011 because SSD was not indpendent on January 1st 2011
#' x <- state_panel(2011, 2013, partial = "first")
#' dplyr::filter(x, gwcode==626)
#'
#' # Includes 2011 because 12-31 date is used for filtering
#' x <- state_panel("2011-12-31", "2013-12-31", by = "year", partial = "exact")
#' dplyr::filter(x, gwcode==626)
#'
#' # Includes 2011 because partial = "any"
#' x <- state_panel("2011-01-01", "2013-01-01", by = "year", partial = "any")
#' dplyr::filter(x, gwcode==626)
#'
#' @export
#' @importFrom utils data
#' @importFrom dplyr filter select mutate arrange full_join "%>%"
state_panel <- function(start, end, by = NULL, partial = "any", useGW = TRUE) {

  dates  <- c(start, end)
  period <- sapply(dates, id_period)

  # Input validation
  if (length(unique(period)) > 1) {
    stop(sprintf("Found multiple implied time periods (%s)",
                 paste(period, collapse = ", ")))
  }

  stopifnot(
    all(!is.na(dates)),
    length(start)==1,
    length(end)==1
  )

  period <- unique(period)

  if (!is.null(by)) {
    if (!by %in% c("year", "month", "day")) {
      stop("Only 'year', 'month', and 'day' are currently supported for the 'by' argument.")
    }
  }
  if (!partial %in% c("exact", "any", "first", "last")) {
    stop("Only 'exact', 'any', 'last', and 'first' options are supported for 'partial' argument.")
  }
  # partial = "exact" requires Dates as input
  is_date <- methods::is(dates, "Date") | period=="day"
  if (partial=="exact" & !is_date) {
    stop("Option 'partial = \"exact\"' requires date input for 'start' and 'end'")
  }
  # if start and end are proper dates, require by argument
  if (period=="day" & is.null(by)) {
    stop("'by' argument is required with date 'start' and 'end' input")
  }

  start <- parse_date(start)
  end   <- parse_date(end)

  # Infer 'by' if it is null
  if (is.null(by)) {
    by = period
  }

  panel <- state_panel_date(start, end, by, partial, useGW)

  panel <- panel %>% dplyr::arrange(ccode, date)
  colnames(panel) <- c(ifelse(useGW, "gwcode", "cowcode"), "date")

  if (by=="year") {
    panel$year <- as.integer(substr(panel$date, 1, 4))
    panel$date <- NULL
  }

  panel <- as.data.frame(panel)
  panel
}

utils::globalVariables(c("ccode", "cend", "cstart", "datestr"))

#' State panel constructor
#'
#' Internal state panel constructor without input checking and fluff to allow
#' argument shortcuts like start = 2000 instead of a full date
#'
#' @param start length 1 date
#' @param end length 1 date
#' @param by time period
#' @param partial how to handle partial interval overlap
#' @param useGW Use G&W statelist (`TRUE`), or COW (`FALSE`)?
#'
#' @keywords internal
state_panel_date <- function(start, end, by, partial, useGW) {

  if (useGW) {
    statelist <- states::gwstates[, c("gwcode", "start", "end")]
  } else {
    statelist <- states::cowstates[, c("cowcode", "start", "end")]
  }
  colnames(statelist) <- c("ccode", "cstart", "cend")

  # Filter records outside desired date range
  statelist <- statelist[with(statelist, cend >= start & cstart <= end), ]

  # For partial = "any", we can get the correct states by adjusting both the
  # input start and end date and state start and end dates to period index
  # dates
  if (partial=="any") {
    statelist$cstart <- index_date(statelist$cstart, period = by)
    statelist$cend   <- index_date(statelist$cend, period = by)
  }

  # Adjust start and end dates. For "exact" we leave as are
  if (partial %in% c("any", "first")) {
    start <- index_date(start, period = by)
    end   <- index_date(end, period = by)
  } else if (partial=="last") {
    if (by == "year") {
      start <- as.Date(sprintf("%s-12-31", substr(start, 1, 4)), format = "%Y-%m-%d")
      end   <- as.Date(sprintf("%s-12-31", substr(end, 1, 4)), format = "%Y-%m-%d")
    } else {
      stop("Not implemented")
    }
  }

  dates <- data.frame(date = seq(start, end, by = by), dummy = 1)

  statelist$dummy <- 1
  super_panel     <- dplyr::full_join(statelist, dates, by = "dummy")
  super_panel$dummy <- NULL

  # Cut excess non-independent country-years from panel
  panel <- subset(super_panel, with(super_panel, cstart <= date & cend >= date))
  panel <- panel[, c("ccode", "date")]
  panel
}
