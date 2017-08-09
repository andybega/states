#' Attempt to convert input to date
#'
#' @param date Date
#' @param by Temporal resolution
#'
attempt_date <- function(date, by) {
  if (!class(date)=="Date") {
    try(date <- as.Date(date), silent=TRUE)
    if (class(date)=="Date") {
      message("Converting to date")
    } else if (by=="year") {
      try(date <- as.Date(paste0(date, "-06-30")), silent=TRUE)
      if (class(date)=="Date") {
        message("Converting to date with yyyy-06-30")
      }
    } else if (by=="month") {
      try(date <- as.Date(paste0(date, "-15")), silent=TRUE)
      if (class(date)=="Date") {
        message("Converting to date with yyyy-mm-15")
      }
    }
  }
  if (!class(date)=="Date") {
    stop(paste("Could not convert to class 'Date'"))
  }
  return(date)
}

#' Create state panel data
#'
#' Create panel data consisting of independent states in the international system.
#'
#' @param start_date Beginning date for data
#' @param end_date End date for data
#' @param by Temporal resolution
#' @param useGW Use Gleditsch & Ward statelist or Correlates of War state system
#'     membership list.
#'
#' @examples
#' begin <- as.Date("1991-01-01")
#' end   <- as.Date("2015-01-01")
#' gwlist  <- state_panel(begin, end, by = "year", useGW = TRUE)
#' cowlist <- state_panel(begin, end, by = "year", useGW = FALSE)
#'
#' @export
#' @importFrom utils data
state_panel <- function(start_date, end_date, by = "month", useGW=TRUE) {
  # problem potentially for situations where two cases with same ccode, and adjacent
  # dates are inclusive, since cshapes end/start dates are not overlapping
  start_date <- attempt_date(start_date, by)
  end_date   <- attempt_date(end_date,   by)

  if (useGW) {
    utils::data("gwstates", envir = environment())
    states <- gwstates[, c("gwcode", "start", "end")]
  } else {
    utils::data("cowstates", envir = environment())
    states <- cowstates[, c("cowcode", "start", "end")]
  }
  colnames(states) <- c("c_code", "c_start", "c_end")
  states <- states[!is.na(states$c_start), ]

  if (end_date > max(states$c_end)) {
    message(sprintf("end_date exceeds %s end date, using state of world in %s\nThis is not a problem unless new states have formed since then.",
                    ifelse(useGW, "G&W list", "COW list"),
                    max(states$c_end)))
  }
  states$c_end[states$c_end==max(states$c_end)] <- end_date

  # Prune country list
  states <- states[with(states, c_end > start_date & c_start < end_date), ]
  date_range <- seq.Date(start_date, end_date, by = by)
  states$id <- 1:nrow(states)
  df <- expand.grid(states$id, date_range)
  colnames(df) <- c("id", "date")
  states <- states[, c("id", "c_code", "c_start", "c_end")]
  df <- dplyr::left_join(df, states, by = "id")
  df <- df[with(df, date >= c_start & date <= c_end), c("c_code", "date")]
  colnames(df) <- c(ifelse(useGW, "gwcode", "cowcode"), "date")

  df
}


