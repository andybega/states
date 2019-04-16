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
#'  \item{`gwcode`}{Gleditsch and Ward country code.}
#'  \item{`iso3c`}{ISO 3 character country code.}
#'  \item{`country_name`}{Long form country name}
#'  \item{`start`}{Country start of independence.}
#'  \item{`end`}{Country end of independence.}
#'  \item{`microstate`}{Logical flag for whether state is a microstates with less than 250,000 population.}
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
#'  \item{`ccode`}{Gleditsch and Ward country code.}
#'  \item{`iso3c`}{ISO 3 character country code.}
#'  \item{`country_name`}{Long form country name}
#'  \item{`start`}{Country start of independence.}
#'  \item{`end`}{Country end of independence.}
#'  \item{`microstate`}{Logical flag for whether state is a microstates with less than 250,000 population.}
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

#' @docType data
#'
#' @name polity
#'
#' @title Polity IV combined Polity scores
#'
#' @description Polity scores reflect how democratic or autocratic countries are
#'   from a scale of -10 (autocratic) to 10 (democratic). There are also three
#'   special codes for foreign "interruption" (-66), anarchy (-77), and transition
#'   periods (-88).
#'
#'   The data are included here for as an example for use with the missing plot.
#'   Thus they do not contain all available Polity indicators, which are
#'   available at the Polity project website www.systemicpeace.org.
#'
#' @usage polity
#'
#' @format Data frame
#' \describe{
#'  \item{`ccode`}{Correlates of War (COW) country code.}
#'  \item{`year`}{Year of the observation.}
#'  \item{`polity`}{Combined Polity score.}
#'}
#'
#' @source
#' Marshall, Monty G., Ted Robert Gurr, and Keith Jaggers. 2017. ``Polity IV
#'   Project: Dataset Users' Manual.'' http://www.systemicpeace.org/inscr/p4manualv2016.pdf
#'
#' @examples
#' data("polity")
#' head("polity")
"polity"



#' Lookup country codes or names
#'
#' Helper to look up state list entries by country code or name
#'
#' @param x The search string or number.
#' @param list Which state list to search (both, GW, or COW only)
#'
#' @examples
#' # Works with either integer or strings
#' sfind(325)
#' sfind("ALG")
#' sfind("Algeria")
#'
#' # Search strings are treated as regular expressions (see stringr::str_detect)
#' sfind("Germany")
#' sfind("German")
#' @export
sfind <- function(x, list = "both") {

  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("stringr needed for this function to work. Please install it.",
         call. = FALSE)
  }

  gwstates  <- states::gwstates
  cowstates <- states::cowstates

  colnames(gwstates)[1]  <- "ccode"
  colnames(gwstates)[2]  <- "code3c"
  colnames(cowstates)[1] <- "ccode"
  colnames(cowstates)[2] <- "code3c"

  slist <- rbind(
    cbind(list = "GW", gwstates),
    cbind(list = "COW", cowstates, microstate = NA)
  )
  slist$search_string <- paste0(slist$code3c, ";", slist$country_name)
  slist$search_string <- tolower(slist$search_string)

  if (list != "both") {
    slist <- slist[slist$list==list, ]
  }

  # check if input query is numeric, otherwise transform to lowercase
  x_is_numeric <- suppressWarnings(!is.na(as.numeric(as.character(x))))
  if (x_is_numeric) {
    x <- as.numeric(x)
  } else {
    x <- tolower(as.character(x))
  }

  if (x_is_numeric) {
    res <- slist[slist$ccode==x, ]
  } else {
    res <- slist[stringr::str_detect(slist$search_string, x), ]
  }
  res$search_string <- NULL
  res
}
