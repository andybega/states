#' Compare two statelists
#'
#' Check set overlap between two state lists / data frames, e.g.
#' prior to merging them.
#'
#' @param df1 data frame
#' @param df2 data frame
#' @param state1 (`character(1)`) Name of the country ID var in df1, default
#'   "gwcode"
#' @param state2 (`character(1)`) Name of the country ID var in df2, default
#'   "gwcode"
#' @param time1 (`character(1)`) Name of the time ID var in df1, default "year"
#' @param time2 (`character(1)`) Name of the time ID var in df2, default "year"
#'
#' @details This is a helper for interactively debugging data merges for data
#'   that may have slightly different state lists. For example, these
#'   differences in case sets could be because of country code differences.
#'
#' @examples
#' # df2 has all countries in 2018 but some values in x1 are missing
#' df1 <- state_panel(2018, 2018, partial = "any")
#' df1$year <- as.integer(substr(df1$date, 1, 4))
#' df1$date <- NULL
#' df1$x1 <- round(runif(nrow(df1))*5)
#' df1$x1[sample.int(nrow(df1), size = 20, replace = FALSE)] <- NA
#'
#' # df2 is missing some countries and also has missing values in x2
#' df2 <- state_panel(2018, 2018, partial = "any")
#' df2$year <- as.integer(substr(df2$date, 1, 4))
#' df2$date <- NULL
#' df2 <- df2[sample.int(nrow(df2), size = 150), ]
#' df2$x2 <- round(runif(nrow(df2))*5)
#' df2$x2[sample.int(nrow(df2), size = 20, replace = FALSE)] <- NA
#'
#' comp <- compare(df1, df2)
#' comp
#'
#'
#' @export
compare <- function(df1, df2, state1 = "gwcode", time1 = "year",
                                 state2 = "gwcode", time2 = "year") {
  stopifnot(!any(is.na(df1[, state1])),
            !any(is.na(df1[, time1])),
            !any(is.na(df2[, state2])),
            !any(is.na(df2[, time2])))

  # Summarize the data frames and discard vars
  missval_df1      <- 1L - as.integer(complete.cases(df1))
  df1              <- df1[, c(state1, time1)]
  df1$case_in_df1  <- 1L
  df1$missval_df1  <- missval_df1

  missval_df2      <- 1L - as.integer(complete.cases(df2))
  df2              <- df2[, c(state2, time2)]
  df2$case_in_df2  <- 1L
  df2$missval_df2  <- missval_df2

  # Combine and start getting set overlap
  df <- merge(df1, df2, all = TRUE,
              by.x = c(state1, time1), by.y = c(state2, time2))
  df <- df[order(df[, state1], df[, time1]), ]
  df$case_in_df1[is.na(df$case_in_df1)] <- 0L
  df$case_in_df2[is.na(df$case_in_df2)] <- 0L

  # for missval, if the case is not in a dataset, we don't know. Code an
  # explicit value for this
  lbls <- c("0", "1", "unknown")
  df$missval_df1 <- factor(df$missval_df1, levels = c(0, 1, NA), labels = lbls,
                           exclude = NULL)
  df$missval_df2 <- factor(df$missval_df2, levels = c(0, 1, NA), labels = lbls,
                           exclude = NULL)


  class(df) <- c("state_sets", class(df))
  df
}

#' @export
#' @importFrom rlang .data
summary.state_sets <- function(object, ...) {
  tbl <- object %>%
    dplyr::group_by(.data$case_in_df1, .data$case_in_df2,
                    .data$missval_df1, .data$missval_df2) %>%
    dplyr::summarize(n = dplyr::n()) %>%
    dplyr::ungroup()
  tbl
}


#' @export
print.state_sets <- function(x, ...) {
  print(summary(x))
}


#' @param cases ("both", "in df1", "in df2")
subset.state_sets <- function(x, cases = "both", missvals = "either") {

  NULL

}


#' @export
#' @rdname compare
#' @param x a "state_sets" object produced by `compare()`
report <- function(x) {

  splits <- split(x, x[, c("case_in_df1", "case_in_df2", "missval_df1", "missval_df2")])
  splits <- splits[sapply(splits, nrow) > 0]
  set    <- names(splits)

  # some combinations are impossible, e.g. we don't know anything about
  # cases that are missing from both data sets, and we also don't know anything
  # about the completeness of records from cases that are missing in one dataset
  set_text <- list(
    "1.1.0.0" = "match and have no missing values",
    "1.1.1.1" = "match but have missing values in both",
    "1.1.0.1" = "match but have missing values in df2",
    "1.1.1.0" = "match but have missing values in df1",
    "1.0.0.unknown" = "in df1 (no missing values) but not df2",
    "1.0.1.unknown" = "in df1 (with missing values) but not df2",
    "0.1.unknown.0" = "not in df1 but in df2 (no missing values)",
    "0.1.unknown.1" = "not in df1 but in df2 (with missing values)"
  )

  outstr <- ""
  outstr <- paste0(outstr, (sprintf("%s total rows\n", nrow(x))))
  outstr <- paste0(outstr, sprintf("%s rows in df1\n", sum(x$case_in_df1)))
  outstr <- paste0(outstr, sprintf("%s rows in df2\n", sum(x$case_in_df2)))

  for (i in 1:length(set_text)) {
    set_name <- names(set_text)[i]
    if (!set_name %in% names(splits)) next
    set_df   <- splits[[set_name]]
    outstr <- paste0(outstr, sprintf("\n%s rows %s\n", nrow(set_df), set_text[[i]]))
    cy_str <- paste(set_df[, 1], set_df[, 2], sep = "-")
    if (length(cy_str) > 10) {
      cy_str <- c(utils::head(cy_str, 10), sprintf("and %s more", length(cy_str) - 10))
    }
    cy_str <- paste0(paste0(cy_str, collapse = ", "), "\n")
    outstr <- paste0(outstr, cy_str)
  }
  cat(paste0(outstr, collapse = "\n"))
  invisible(outstr)
}


