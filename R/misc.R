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
#'
#' # Shortcut for integer years:
#' yr <- c(2002:2005, 2007:2010)
#' data.frame(year = yr, id = id_date_sequence(yr))
id_date_sequence <- function(x, pd = NULL) {

  # shortcut: if x is integer assume that it is years
  if (!inherits(x, "Date")) {

    stopifnot(
      is.numeric(x),
      all(x > 1815),
      all(x < 10000)
    )

    # years should increase by 1, if there is a gap the step will be >1
    diff_x <- c(1, diff(x))
    # id gaps and use them to increment an integer ID
    # the +1 at the end is so that the first ID starts at 1 (not 0)
    return(cumsum(diff_x!=1) + 1)

  } else {

    if (is.null(pd)) {
      stop("Please specify the time period for x")
    }

    diff_days <- diff(x)
    divisor <- NA
    if (pd=="month") divisor <- 365.25/12
    if (pd=="week") divisor <- 7
    if (pd=="year") divisor <- 365.25
    if (pd=="day") divisor <- 1
    if (is.na(divisor)) stop("Did not recognize time period")
    xx <- c(1, round(diff_days / divisor))
    return(cumsum(xx!=1) + 1)
  }
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

  if (list=="GW") {
    cnames <- states::gwstates
    cnames$countrycode = cnames$gwcode
  } else {
    cnames <- states::cowstates
    cnames$countrycode = cnames$cowcode
  }

  cnames <- cnames %>%
    dplyr::group_by(.data$countrycode) %>%
    dplyr::summarize(country_name = tail(unique(.data$country_name), 1),
                     .groups = "drop")

  if (isTRUE(shorten)) {
    cnames$country_name <- prettyc(cnames$country_name)
  }

  data.frame(countrycode = x) %>%
    dplyr::left_join(cnames, by = "countrycode") %>%
    dplyr::pull(.data$country_name)
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
    "United Kingdom", "UK",
    "United States of America", "USA",
    "Venezuela, Bolivarian Republic of", "Venezuela",
    "Vietnam \\(Annam/Cochin China/Tonkin\\)", "Vietnam",
    "Vietnam, Democratic Republic of", "Vietnam",
    "Vietnam, Republic of", "South Vietnam",
    "Yemen Arab Republic", "Yemen",
    "Yemen \\(Arab Republic of Yemen\\)", "Yemen",
    "Yemen, People's Republic of", "South Yemen",
    "United Provinces of Central America", "FR Central America",
    "Saint Vincent and the Grenadines", "Saint Vincent",
    "Belarus \\(Byelorussia\\)", "Belarus",
    "Kyrgyz Republic", "Kyrgyzstan",
    "Zimbabwe \\(Rhodesia\\)", "Zimbabwe"
    )
  )
  for (i in 1:nrow(dict)) {
    cn <- gsub(dict[i, 1], dict[i, 2], cn)
  }
  cn
}

