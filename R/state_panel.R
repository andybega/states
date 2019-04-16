#' Create state panel data
#'
#' Create panel data consisting of independent states in the international system.
#'
#' @param start Beginning date for data
#' @param end End date for data
#' @param by Temporal resolution, "year", "month", or "day".
#' @param partial Option for how to handle edge cases where a state is independent
#'   for only part of a time period (year, month, etc.). Options include
#'   `"exact"`, and `"any"`. See details.
#' @param useGW Use Gleditsch & Ward statelist or Correlates of War state system
#'     membership list.
#'
#' @details
#' The partial option determines how to handle instances where a country gains
#' or loses independence during a time period specified in the by option:
#'
#' \itemize{
#'     \item{"exact": the exact date in start is used for filtering}
#'     \item{"any": a state-period is included if the state was independent at
#'                  any point in that period.}
#' }
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
#' # No 2011 because SSD was not indpendent on January 1st 2011
#' x <- state_panel("2011-01-01", "2013-01-01", by = "year", partial = "exact")
#' dplyr::filter(x, gwcode==626)
#' # Includes 2011 because 12-31 date is used for filtering
#' x <- state_panel("2011-12-31", "2013-12-31", by = "year", partial = "exact")
#' dplyr::filter(x, gwcode==626)
#' # Includes 2011 because partial = "any"
#' x <- state_panel("2011-01-01", "2013-01-01", by = "year", partial = "any")
#' dplyr::filter(x, gwcode==626)
#'
#' @export
#' @importFrom utils data
#' @importFrom dplyr filter select mutate arrange full_join "%>%"
state_panel <- function(start, end, by = "year", partial = "exact", useGW=TRUE) {

  # Input validation
  if (!by %in% c("year", "month", "day")) {
    stop("Only 'year', 'month', and 'day' are currently supported for the 'by' argument.")
  }
  if (!partial %in% c("exact", "any")) {
    stop("Only 'exact' and 'any' options are supported for 'partial' argument.")
  }
  dates <- c(start, end)
  yyyy <- all(grepl("^[0-9]{4}$", dates))
  yyyymmdd <- all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}", dates))
  if (!any(yyyy, yyyymmdd)) {
    stop("Invalid start/end input, format should be either 'YYYY' or 'YYYY-MM-DD'.")
  }

  # Parse YYYY input
  if (yyyy) {
    start   <- paste0(start, "-01-01")
    end     <- paste0(end, "-01-01")
    by      <- "year"
    partial <- "any"
  }

  # Date validation
  start <- as.Date(start)
  end   <- as.Date(end)
  if (is.na(start) | is.na(end)) {
    stop("Could not convert start or end to Date class.")
  }


  if (useGW) {
    utils::data("gwstates", envir = environment())
    statelist <- gwstates[, c("gwcode", "start", "end")]
  } else {
    utils::data("cowstates", envir = environment())
    statelist <- cowstates[, c("cowcode", "start", "end")]
  }
  colnames(statelist) <- c("ccode", "cstart", "cend")

  # Update country end dates for currently existing countries
  if (end > max(statelist$cend)) {
    statelist$cend[statelist$cend==max(statelist$cend)] <- end
  }
  # Filter records outside desired date range
  statelist <- statelist[with(statelist, cend >= start & cstart <= end), ]

  statelist$dummy <- 1
  dates <- data.frame(dummy = 1,
                     date = seq(start, end, by = by))
  panel <- dplyr::full_join(statelist, dates, by = "dummy") %>%
    dplyr::select(-dummy)

  if (partial == "exact") {
    panel <- panel %>%
      dplyr::filter(cstart <= date & cend >= date) %>%
      dplyr::select(-cstart, -cend)
  } else if (partial == "any") {
    if (by == "year") {
      panel$datestr <- as.integer(substr(panel$date, 1, 4))
      panel$cstart <- as.integer(substr(panel$cstart, 1, 4))
      panel$cend   <- as.integer(substr(panel$cend, 1, 4))
      panel <- panel %>%
        dplyr::filter(cstart <= datestr & cend >= datestr) %>%
        dplyr::select(-cstart, -cend, -datestr)
    } else if (by == "month") {
      panel <- panel %>%
        dplyr::mutate(datestr = substr(date, 1, 7),
                      cstart  = substr(cstart, 1, 7),
                      cend    = substr(cend, 1, 7)) %>%
        dplyr::filter(cstart <= datestr & cend >= datestr) %>%
        dplyr::select(-cstart, -cend, -datestr)
    } else if (by == "day") {
      # same as exact
      panel <- panel %>%
        dplyr::filter(cstart <= date & cend >= date) %>%
        dplyr::select(-cstart, -cend)
    }
  }

  panel <- panel %>% dplyr::arrange(ccode, date)
  colnames(panel) <- c(ifelse(useGW, "gwcode", "cowcode"), "date")
  panel <- as.data.frame(panel)
  panel
}

utils::globalVariables(c("ccode", "cend", "cstart", "datestr", "dummy"))
