#' Visualize missing and non-proper cases for state panel data
#'
#' Plot missing values by country and date, and additionally identify country-date
#' cases that do or do not match an independent state list.
#'
#' @param data State panel data frame
#' @param x Variable names(s), e.g. "x" or c("x1", "x2"). Default is NULL, in
#'    which case all columns expect the space and time ID columns will be used.
#' @param space Name of variable identifying state country codes. If NULL
#'    (default) and one of "gwcode" or "cowcode" is a column in the data, it
#'    will be used.
#' @param time Name of time identifier, the corresponding variables needs to be
#'     Date class. Default is "date".
#' @param period Temporal resolution character string, e.g. "year" or "month".
#'     See details in [base::seq.Date()]. Default is "year".
#' @param statelist Check not only missing values, but presence or absence of
#'     observations against a list of independent states? "none" or "GW" or "COW".
#' @param skip_labels Only plot the label for every n-th country on the y-axis
#'     to avoid overplotting.
#' @param partial Option for how to handle edge cases where a state is independent
#'   for only part of a time period (year, month, etc.). Options include
#'   "exact", and "any". See [state_panel()] for details.
#'
#' @details `missing_info` provides the information that is plotted with
#'     `plot_missing`. The latter returns a ggplot, and thus can be chained
#'     with other ggplot functions as usual.
#'
#' @return `plot_missing` returns a ggplot2 object.
#'
#'   `missing_info` returns a data frame with components:
#'   \item{space}{Space identifier, with name equal to the "space" argument, e.g. "ccode".}
#'   \item{time}{Time identifier, with name equal to the "time" argument, e.g. "date".}
#'   \item{independent}{A logical vector, is the statelist argument is none, NA.}
#'   \item{missing_value}{A logical vector indicating if that record has missing values}
#'   \item{status}{The label used for plotting, combining the independence and missing value information for a case as appropriate.}
#'
#' @export
#' @importFrom grDevices hcl
#' @md
#'
#' @examples
#' # Create an example data frame with missing values
#' cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
#' useGW = TRUE)
#' cy$myvar <- rnorm(nrow(cy))
#' cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA
#' str(cy)
#'
#' # Visualize missing values:
#' plot_missing("myvar", cy, "gwcode", "date", "year", "none")
#'
#' # missing_info() generates the data underlying plot_missing():
#' head(missing_info("myvar", cy, "gwcode", "date", "year", "none"))
#'
#' # if we specify a statelist to check against, 'independent' will have values
#' # now:
#' head(missing_info("myvar", cy, "gwcode", "date", "year", "GW"))
#'
#' # Check data also against G&W list of independent states
#' head(missing_info("myvar", cy, "gwcode", "date", "year", "GW"))
#' plot_missing("myvar", cy, "gwcode", "date", "year", "GW")
#'
#' # To check all variables:
#' # plot_missing(setdiff(colnames(df), "space", "time"), ...)
#'
#' # Live example with Polity data
#' data("polity")
#' head(polity)
#' polity$date <- as.Date(paste0(polity$year, "-12-31"))
#' plot_missing(polity, "polity", "ccode", "date", "year", "COW")
#' # COW starts in 1816; Polity has excess data for several non-independent
#' # states after that date, and is missing coverage for several countries.
#'
#' # The date option is relevant for years in which states gain or lose
#' # independence, so this will be slighlty different:
#' polity$date <- as.Date(paste0(polity$year, "-01-01"))
#' plot_missing(polity, "polity", "ccode", "date", "year", "COW")
#'
#' # plot_missing returns a ggplot2 object, so you can do anything you want
#' plot_missing(polity, "polity", "ccode", "date", "year", "COW") +
#'   ggplot2::coord_flip()
plot_missing <- function(data, x = NULL, space = NULL, time = "date", period = "year",
                         statelist = "none", skip_labels = 5, partial = "exact") {

  # Temporary code for data, x argument order switch
  args <- .warner(data, x)
  data <- args$data
  x    <- args$x
  rm(args)

  # Try to find ID columns if not specified
  if (is.null(space)) {
    space <- id_space_column(data)
  }

  if (!statelist %in% c("none", "GW", "COW")) {
    stop(sprintf("'%s' is not a valid option for 'statelist', use 'none', 'GW', or 'COW'",
                 statelist))
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 needed for this function to work. Please install it.",
         call. = FALSE)
  }

  data <- as.data.frame(data)

  mm <- missing_info(data, x, space, time, period, statelist, partial)

  if (statelist %in% c("GW", "COW")) {
    fill_values <- c("Complete, independent" = hcl(195, 100, 65), "Complete, non-independent" = hcl(15, 100, 20),
                     "Missing values, independent"  = hcl(15, 100, 65), "Missing values, non-independent"  = hcl(15, 100, 45),
                     "No observation, independent"   = hcl(15, 100, 85), "No observation, non-independent"   = hcl(15, 0, 97))
  } else {
    fill_values <-  c("Complete"         = grDevices::hcl(195, l=65, c=100),
                      "Missing values"   = grDevices::hcl(15, l=65, c=100),
                      "No observation"   = grDevices::hcl(15, l=97, c=0))
  }

  # Skip labels to avoid overplotting
  brks <- sort(unique(mm[, space]), decreasing = T)
  brks <- brks[seq(1, length(brks), by = skip_labels)]

  p <- ggplot2::ggplot(mm, ggplot2::aes_string(x = time, y = space, fill = "status")) +
    ggplot2::geom_tile() +
    ggplot2::scale_y_discrete(breaks = brks) +
    ggplot2::scale_x_date(expand=c(0, 0)) +
    ggplot2::scale_fill_manual("", drop = FALSE, values = fill_values) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = 2)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom")
  p
}



#' @export
#' @rdname plot_missing
#' @importFrom stats complete.cases
missing_info <- function(data, x = NULL, space = NULL, time = "date", period = "year",
                         statelist = "none", partial = "exact") {

  # Temporary code for data, x argument order switch
  args <- .warner(data, x)
  data <- args$data
  x    <- args$x
  rm(args)

  # Try to find ID columns if not specified
  if (is.null(space)) {
    space <- id_space_column(data)
  }

  df <- as.data.frame(data)

  # Check space ID has no missing values
  if (any(is.na(df[, space]))) {
    stop(paste0("Space identifier '", space, "' contains missing values."))
  }

  # Check time ID has no missing values
  if (any(is.na(df[, time]))) {
    stop(paste0("Time identifier '", time, "' contains missing values."))
  }

  # Check time variable is class Date
  if (!inherits(df[, time], "Date")) {
    stop(sprintf("Time identifier '%s' must be a Date object", time))
  }

  # Check correct option for statelist
  if (!statelist %in% c("none", "GW", "COW")) {
    stop("Valid choices for statelist argument are 'none', 'GW', or 'COW'")
  }

  # Infer x variables if not specified; have to do this after already infering
  # space, time, and period, if needed
  if (is.null(x)) {
    x <- setdiff(colnames(data), c(space, time))
  }

  # Create missingness logical vector
  df[, "missing_value"] <- !stats::complete.cases(df[, x])
  df <- df[, c(space, time, "missing_value")]

  if (statelist=="none") {
    if (!is.factor(df[, space])) df[, space] <- as.factor(df[, space])
    space_range <- unique(df[, space])
    time_range  <- seq.Date(from = min(data[, time]),
                            to   = max(data[, time]),
                            by   = period
    )
    full_mat <- expand.grid(space_range, time_range)
    colnames(full_mat) <- c(space, time)

    full_mat$independent <- NA

    full_mat <- dplyr::left_join(full_mat, df, by = c(space, time))
    full_mat$status <- NA
    full_mat$status[full_mat$missing_value==TRUE]  <- "Missing values"
    full_mat$status[full_mat$missing_value==FALSE] <- "Complete"
    full_mat$status[is.na(full_mat$missing_value)] <- "No observation"
    stopifnot(!any(is.na(full_mat$status)))
    full_mat$status <- factor(full_mat$status, levels = c("Complete", "Missing values", "No observation"))

  } else {

    ccname <- ifelse(statelist=="GW", "gwcode", "cowcode")
    ind_states <- state_panel(min(df[, time]), max(df[, time]), by = period,
                              useGW = (statelist=="GW"), partial = partial)
    colnames(ind_states)  <- c(space, time)
    ind_states$independent <- 1

    full_mat <- dplyr::full_join(ind_states, df, by = c(space, time))

    full_mat$independent[is.na(full_mat$independent)] <- 0

    full_mat$status[full_mat$missing_value==TRUE]  <- "Missing values"
    full_mat$status[full_mat$missing_value==FALSE] <- "Complete"
    full_mat$status[is.na(full_mat$missing_value)] <- "No observation"

    full_mat$status <- paste(full_mat$status,
                             ifelse(full_mat$independent,
                                    "independent",
                                    "non-independent"),
                             sep = ", ")
    lvls        <- as.vector(
      outer(c("Complete", "Missing values", "No observation"),
      c("independent", "non-independent"), paste, sep = ", ")
      )
    full_mat$status <- factor(full_mat$status, levels = lvls)
  }

  # Reorder for ggplot2 plotting
  full_mat[, space] <- factor(full_mat[, space], levels = rev(sort(unique(full_mat[, space]))))
  full_mat
}


#' Temporary helper function to warn about argument order change
#'
#' @param data data.frame
#' @param x string
.warner <- function(data, x) {
  if (inherits(x, "data.frame") & class(data)[1]=="character") {
    warning("The order of the 'data' and 'x' arguments has switched, please adjust code accordingly.\nplot_missing(data, x, ...)\nmissing_info(data, x, ...)")
    return(list(data = x, x = data))
  }
  list(data = data, x = x)
}


id_space_column <- function(data) {
  idx <- c("gwcode", "cowcode") %in% colnames(data)
  if (!any(idx)) {
    stop("Please specifiy the \"space\" argument")
  }
  if (all(idx)) {
    warning("Found both \"gwcode\" and \"cowcode\" columns in data, using \"gwcode\".")
    space <- "gwcode"
  }
  if (xor(idx[1], idx[2])) {
    space <- c("gwcode", "cowcode")[idx]
  }
  space
}
