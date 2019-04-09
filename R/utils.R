#' Identify date sequences
#'
#' For correctly plotting country-time period spells
#'
#' @param x a Date sequence
#' @param pd what is the time aggregation period in the data?
#'
#' @export
#'
#' @examples
#' library("ggplot2")
#' d1 <- as.Date("2018-01-01")
#' d2 <- as.Date("2025-01-01")
#' seq1 <- seq(d1, d2, by = "year")
#' data.frame(seq1, id=id_date_sequence(seq1, "year"))
#' # With a gap, should be two ids
#' df <- data.frame(date = seq1[-4], id=id_date_sequence(seq1[-4], "year"), cowcode = 999)
#' df
#'
#' # The point is to plot countries with interrupted independence correctly:
#' df$y <- c(rep(1, 3), rep(2, 4))
#' df$id <- paste0(df$cowcode, df$id)
#' df
#' ggplot(df, aes(x = date, y = y, group = cowcode)) + geom_line()
#' ggplot(df, aes(x = date, y = y, group = id)) + geom_line()
id_date_sequence <- function(x, pd) {
  diff_days <- diff(x)
  divisor <- NA
  if (pd=="month") divisor <- 365.25/12
  if (pd=="week") divisor <- 7
  if (pd=="year") divisor <- 365.25
  if (pd=="day") divisor <- 1
  if (is.na(divisor)) stop("Did not recognize time period")
  xx <- c(1, round(diff_days / divisor))
  cumsum(xx!=1) + 1
}


#' Country names
#'
#' @param x A vector of numeric country codes
#' @param list Which states list to use? Only "GW" at this time.
#'
#' @examples
#' data("gwstates")
#' codes <- gwstates$gwcode
#' cn    <- country_names(codes)
#' data.frame(gwcode = codes, country_name = cn)
#'
#' @export
country_names <- function(x, list = "GW") {
  cnames <- states::gwstates %>%
    dplyr::group_by(gwcode) %>%
    dplyr::summarize(country_name = tail(unique(country_name), 1))
  data.frame(gwcode = x) %>%
    dplyr::left_join(cnames, by = "gwcode") %>%
    dplyr::pull(country_name)
}
