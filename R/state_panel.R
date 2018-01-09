#' Create state panel data
#'
#' Create panel data consisting of independent states in the international system.
#'
#' @param start Beginning date for data
#' @param end End date for data
#' @param by Temporal resolution, "year", "month", or "day".
#' @param partial Option for how to handle edge cases where a state is independent
#'   for only part of a time period (year, month, etc.). Options include
#'   \code{"exact"}, and \code{"any"}. See details.
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
#' gwlist  <- state_panel("1991-01-01", "2015-01-01", by = "year", useGW = TRUE)
#' cowlist <- state_panel("1991-01-01", "2015-01-01", by = "year", useGW = FALSE)
#'
#' @export
#' @importFrom utils data
#' @import lubridate
#' @import dplyr
state_panel <- function(start, end, by = "year", partial = "exact", useGW=TRUE) {

  # Input validation
  start <- as.Date(start)
  end   <- as.Date(end)
  if (is.na(start) | is.na(end)) {
    stop("Could not convert start or end to Date class, are they in 'YYYY-MM-DD' format?")
  }
  if (!by %in% c("year", "month", "day")) {
    stop("Only 'year' and 'month' are currently supported for the 'by' argument.")
  }
  if (!partial %in% c("exact", "any")) {
    stop("Only 'exact' and 'any' options are supported for 'partial' argument.")
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
  dates = data.frame(dummy = 1,
                     date = seq(start, end, by = by))
  panel <- dplyr::full_join(statelist, dates, by = "dummy") %>%
    select(-dummy)

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

  panel <- panel %>% arrange(ccode, date)
  colnames(panel) <- c(ifelse(useGW, "gwcode", "cowcode"), "date")
  panel
}


