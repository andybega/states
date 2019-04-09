#' State system membership
#'
#' @description Create data based on the Gleditsch & Ward (G&W) or Correlates of
#'     War (COW) state system memberships lists. This is useful as a template
#'     for merging other sources of data that have conflicting sets of states.
#'
#' @details See static docs at https://andybeger.com/states and the source code
#'     at https://www.github.com/andybega/states
#'
#' @references
#'     Gleditsch, Kristian S. & Michael D. Ward. 1999. ``Interstate System
#'       Membership: A Revised List of the Independent States since 1816.''
#'       International Interactions 25: 393-413.
#'
#'     Correlates of War Project. 2017. ``State System Membership List, v2016.''
#'       Online, http://correlatesofwar.org
#'
#' @name states
#' @docType package
#'
#' @importFrom utils tail
NULL
globalVariables(c("gwstates", "cowstates"))
