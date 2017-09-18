#' @docType data
#'
#' @name gwstates
#'
#' @title Gleditsch and Ward list of independent states
#'
#' @description A list of independent states and microstates from 1816 on by
#'   Gleditsch and Ward
#'
#' @usage gwstates
#'
#' @format Data frame
#' \describe{
#'  \item{\code{gwcode}}{Gleditsch and Ward country code.}
#'  \item{\code{iso3c}}{ISO 3 character country code.}
#'  \item{\code{country_name}}{Long form country name}
#'  \item{\code{start}}{Country start of independence.}
#'  \item{\code{end}}{Country end of independence.}
#'  \item{\code{microstate}}{Logical flag for whether state is a microstates with less than 250,000 population.}
#'}
#'
#' @source
#' Gleditsch, Kristian S. and Michael D. Ward. 1999. ``Interstate System
#' Membership: A Revised List of the Independent States since 1816."
#' International Interactions 25.
#'
#' @examples
#' data(gwstates)
#' head(gwstates)
"gwstates"


#' @docType data
#'
#' @name cowstates
#'
#' @title Correlates of War list of independent states
#'
#' @description A list of independent states and microstates from 1816 on by
#'   the Correlates of War project.
#'
#' @usage cowstates
#'
#' @format Data frame
#' \describe{
#'  \item{\code{ccode}}{Gleditsch and Ward country code.}
#'  \item{\code{iso3c}}{ISO 3 character country code.}
#'  \item{\code{country_name}}{Long form country name}
#'  \item{\code{start}}{Country start of independence.}
#'  \item{\code{end}}{Country end of independence.}
#'  \item{\code{microstate}}{Logical flag for whether state is a microstates with less than 250,000 population.}
#'}
#'
#' @source
#' Correlates of War Project. 2011. "State System Membership List, v2011."
#' Online, http://correlatesofwar.org
#'
#' @examples
#' data(cowstates)
#' head(cowstates)
"cowstates"



#' Lookup country codes or names
#'
#' Helper to look up state list entries by country code or name
#'
#' @param x The search string or number.
#' @param list Which state list to search. Only G&W at this point.
#'
#' @examples
#' sfind(325)
#' sfind("Algeria")
#'
#' @export
sfind <- function(x, list = "both") {
  gwstates  <- states::gwstates
  cowstates <- states::cowstates

  colnames(gwstates)[1]  <- "ccode"
  colnames(gwstates)[2]  <- "code3c"
  colnames(cowstates)[1] <- "ccode"
  colnames(cowstates)[2] <- "code3c"

  slist <- rbind(
    cbind(list = "G&W", gwstates),
    cbind(list = "COW", cowstates, microstate = NA)
  )
  slist$search_string <- paste0(slist$code3c, ";", slist$country_name)

  requireNamespace("stringr", quietly = TRUE)

  if (list != "both") {
    slist <- slist[slist$list==list, ]
  }

  if (is.numeric(x)) {
    res <- slist[slist$ccode==x, ]
  } else {
    res <- slist[stringr::str_detect(slist$search_string, x), ]
  }
  res$search_string <- NULL
  res
}
