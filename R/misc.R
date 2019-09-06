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
#' @param x ([numeric()])\cr
#'   A vector of numeric country codes
#' @param list (`logical(1)`)\cr
#'   Which states list to use? Only "GW" at this time.
#' @param shorten (`logical(1)`)\cr
#'   Shorten some of the longer country names like "Macedonia, the former Yugoslav Republic of"?
#'
#' @examples
#' data("gwstates")
#' codes <- gwstates$gwcode
#' cn    <- country_names(codes)
#' cs    <- country_names(codes, shorten = TRUE)
#' data.frame(gwcode = codes, country_name = cn, short_names = cs)
#'
#' @export
country_names <- function(x, list = "GW", shorten = FALSE) {
  # hack to avoid globals NOTE;
  # for better, see https://dplyr.tidyverse.org/articles/programming.html
  gwcode <- country_name <- NULL
  cnames <- states::gwstates %>%
    dplyr::group_by(gwcode) %>%
    dplyr::summarize(country_name = tail(unique(country_name), 1))

  if (isTRUE(shorten)) {
    cnames$country_name <- prettyc(cnames$country_name)
  }

  data.frame(gwcode = x) %>%
    dplyr::left_join(cnames, by = "gwcode") %>%
    dplyr::pull(country_name)
}


#' Shorten country names
#'
#' @param x ([character()])\cr
#'   Country names, e.g. from [country_names()].
#'
#' @examples
#' cn <- c(
#'   "Macedonia, the former Yugoslav Republic of",
#'   "Congo, the Democratic Republic of the",
#'   "Tanzania, United Republic of")
#' prettyc(cn)
#'
#' @export
prettyc <- function(x) {
  cn <- x
  dict <- matrix(ncol=2, byrow=TRUE, c(
    "Burkina Faso \\(Upper Volta\\)", "Burkina Faso",
    "Bolivia, Plurinational State of", "Bolivia",
    "Central African Republic", "CAR",
    "Congo, the Democratic Republic of the", "DR Congo",
    "Congo, Democratic Republic of \\(Zaire\\)", "DR Congo",
    "Federal Republic of Germany", "Germany",
    "Federated States of Micronesia", "Micronesia",
    "Korea, Democratic People's Republic of", "North Korea",
    "Korea, People's Republic of", "North Korea",
    "Korea, Republic of", "South Korea",
    "Lao People's Democratic Republic", "Laos",
    "Macedonia, the former Yugoslav Republic of", "North Macedonia",
    "Macedonia \\(Former Yugoslav Republic of\\)", "North Macedonia",
    "Moldova, Republic of", "Moldova",
    "Myanmar \\(Burma\\)", "Myanmar",
    "Iran, Islamic Republic of", "Iran",
    "Iran \\(Persia\\)", "Iran",
    "Russian Federation", "Russia",
    "Sri Lanka \\(Ceylon\\)", "Sri Lanka",
    "Syrian Arab Republic", "Syria",
    "Tanzania, United Republic of", "Tanzania",
    "Tanzania/Tanganyika", "Tanzania",
    "Turkey \\(Ottoman Empire\\)", "Turkey",
    "Venezuela, Bolivarian Republic of", "Venezuela",
    "Vietnam \\(Annam/Cochin China/Tonkin\\)", "Vietnam",
    "Vietnam, Democratic Republic of", "Vietnam",
    "Vietnam, Republic of", "South Vietnam",
    "Yemen Arab Republic", "Yemen",
    "Yemen \\(Arab Republic of Yemen\\)", "Yemen",
    "Yemen, People's Republic of", "South Yemen",
    "United Provinces of Central America", "FR Central America",
    "Saint Vincent and the Grenadines", "Saint Vincent"
    )
  )
  for (i in 1:nrow(dict)) {
    cn <- gsub(dict[i, 1], dict[i, 2], cn)
  }
  cn
}

