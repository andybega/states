#' Visualize missing and non-proper cases for state panel data
#'
#' Plot missing values by country and date, and additionally identify country-date
#' cases that do or do not match an independent state list.
#'
#' @param data State panel data frame
#' @param x Variable names(s), e.g. "x" or c("x1", "x2"). Default is NULL, in
#'    which case all columns expect the ccode and time ID columns will be used.
#' @param ccode Name of variable identifying state country codes. If NULL
#'    (default) and one of "gwcode" or "cowcode" is a column in the data, it
#'    will be used.
#' @param time Name of time identifier. If NULL and a "date" or "year" column
#'    are in the data, they will be used ("year", preferentially, if both are
#'    present)
#' @param period Time period in which the data are. NULL by default and inferred
#'    to be "year" if the "time" column has name "year" or contains integers with
#'    a range between 1799 and 2050. Required if the "time" column is a
#'    [base::Date()] vector to avoid ambiguity.
#' @param statelist Check not only missing values, but presence or absence of
#'     observations against a list of independent states? One of "GW", "COW" or
#'     "none". NULL by default, in which case it will be inferred if the
#'     ccode columns have the name "gwcode" or "cowcode", and "none" otherwise.
#' @param partial Option for how to handle edge cases where a state is independent
#'   for only part of a time period (year, month, etc.). Options include
#'   "exact", and "any". See [state_panel()] for details. If NULL (default) and
#'   the "time" column is a date, it will be set to "exact", for yearly
#'   "time" columns it will be set to "any".
#' @param skip_labels Only plot the label for every n-th country on the y-axis
#'     to avoid overplotting.
#' @param space Deprecated, use "ccode" argument instead.
#'
#' @details `missing_info` provides the information that is plotted with
#'     `plot_missing`. The latter returns a ggplot, and thus can be chained
#'     with other ggplot functions as usual.
#'
#' @return `plot_missing` returns a ggplot2 object.
#'
#'   `missing_info` returns a data frame with components:
#'   \item{ccode}{ccode identifier, with name equal to the "ccode" argument, e.g. "ccode".}
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
#' set.seed(1234)
#' cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA
#' str(cy)
#'
#' # Visualize missing values:
#' plot_missing(cy, statelist = "none")
#'
#' # missing_info() generates the data underlying plot_missing():
#' head(missing_info(cy, statelist =  "none"))
#'
#' # if we specify a statelist to check against, 'independent' will have values
#' # now:
#' head(missing_info(cy, statelist = "GW"))
#'
#' # Check data also against G&W list of independent states
#' head(missing_info(cy, statelist = "GW"))
#' plot_missing(cy, statelist = "GW")
#'
#' # Live example with Polity data
#' data("polity")
#' head(polity)
#' plot_missing(polity, x = "polity", ccode = "ccode", time = "year",
#'              statelist = "COW")
#' # COW starts in 1816; Polity has excess data for several non-independent
#' # states after that date, and is missing coverage for several countries.
#'
#' # The date option is relevant for years in which states gain or lose
#' # independence, so this will be slighlty different:
#' polity$date <- as.Date(paste0(polity$year, "-01-01"))
#' polity$year <- NULL
#' plot_missing(polity, x = "polity", ccode = "ccode", time = "date",
#'              period = "year", statelist = "COW")
#'
#' # plot_missing returns a ggplot2 object, so you can do anything you want
#' polity$year <- as.integer(substr(polity$date, 1, 4))
#' polity$date <- NULL
#' plot_missing(polity, ccode = "ccode", statelist = "COW") +
#'   ggplot2::coord_flip()
#'
#' @importFrom lifecycle deprecated
plot_missing <- function(data, x = NULL, ccode = NULL, time = NULL,
                         period = NULL, statelist = NULL, partial = "any",
                         skip_labels = 5,
                         space = deprecated()) {

  args <- .warner(data, x)
  data <- args$data
  x    <- args$x
  rm(args)

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 needed for this function to work. Please install it.",
         call. = FALSE)
  }

  if (!rlang::is_missing(space)) {
    # v0.3.0, take this out and remove lifecycle dependency at some point
    lifecycle::deprecate_warn("0.3.0", "plot_missing(space = )", "plot_missing(ccode = )")
    ccode <- space
  }

  data <- as.data.frame(data)

  mm <- missing_info(data, x, ccode, time, period, statelist, partial)

  statelist <- attr(mm, "statelist")
  ccode     <- attr(mm, "ccode")
  time      <- attr(mm, "time")

  # Reorder for ggplot2 plotting
  mm[, ccode] <- factor(mm[, ccode], levels = rev(sort(unique(mm[, ccode]))))


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
  brks <- sort(unique(mm[, ccode]), decreasing = T)
  brks <- brks[seq(1, length(brks), by = skip_labels)]

  p <- ggplot2::ggplot(mm, ggplot2::aes(x = .data[[time]], y = .data[[ccode]],
                                        fill = status)) +
    ggplot2::geom_tile(show.legend=TRUE) +
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
missing_info <- function(data, x = NULL, ccode = NULL, time = NULL,
                         period = NULL, statelist = NULL, partial = NULL,
                         space = deprecated()) {

  # Temporary code for data, x argument order switch
  # keep track of original data name for error message below
  data_name <- deparse(substitute(data))
  args <- .warner(data, x)
  data <- args$data
  x    <- args$x
  rm(args)

  data <- as.data.frame(data)

  if (!rlang::is_missing(space)) {
    # v0.3.0, take this out and remove lifecycle dependency at some point
    lifecycle::deprecate_warn("0.3.0", "plot_missing(space = )", "plot_missing(ccode = )")
    ccode <- space
  }

  # Try to find ID columns if not specified
  if (is.null(ccode)) {
    ccode <- id_ccode_column(colnames(data))
  }
  if (any(is.na(data[[ccode]]))) {
    str <- sprintf("data[[\"%s\"]] cannot contain missing values",
                   ccode)
    stop(str)
  }

  if (is.null(time)) {
    time <- id_time_column(colnames(data))
  }
  if (any(is.na(data[[time]]))) {
    str <- sprintf("data[[\"%s\"]] cannot contain missing values",
                   time)
    stop(str)
  }


  if (is.null(period)) {
    if (methods::is(data[[time]], "Date")) {
      stop("Please specify 'period = ', required for Date 'time' columns")
    }
    if (min(data[[time]]) > 1799 & max(data[[time]]) < 2051) {
      period <- "year"
    } else {
      stop("Please specify 'period = ' argument")
    }
  }

  # check if the date input is character YYYY-MM-DD; we can convert to Date
  if (typeof(data[[time]])=="character") {
    if (all(grepl("^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$", data[[time]]))) {
      data[[time]] <- as.Date(data[[time]], format = "%Y-%m-%d")
    } else if (all(grepl("^[0-9]{4}$", data[[time]]))) {
      data[[time]] <- as.integer(data[[time]])
    } else {
      stop("Could not convert character \"time\" column to date or year")
    }
  }

  if (is.null(partial)) {
    if (methods::is(data[[time]], "Date")) {
      partial <- "exact"
    } else {
      partial <- "any"
    }
  }

  # missing_info requires date input, if "year" period with non-Date time
  # the partial argument will adjust the dates anyways, so we can just set
  # to arbitrary
  if (period=="year" & !methods::is(data[[time]], "Date")) {
    if (partial=="exact") {
      stop("This combination of options is not implemented\n(time column is integer, period is year, partial is exact)")
    }
    if (!(min(data[[time]]) > 1799 & max(data[[time]]) < 2051)) {
      stop(sprintf("Can't convert data[[\"%s\"]] to Date", time))
    }
    data[[time]] <- as.Date(paste0(data[[time]], "-01-01"), format = "%Y-%m-%d")
  }

  if (is.null(statelist)) {
    if (ccode=="gwcode") statelist <- "GW"
    if (ccode=="cowcode") statelist <- "COW"
    if (is.null(statelist)) statelist <- "none"
  } else {
    if (!statelist %in% c("none", "GW", "COW")) {
      stop(sprintf("'%s' is not a valid option for 'statelist', use 'none', 'GW', or 'COW'",
                   statelist))
    }
  }

  # Infer x variables if not specified; have to do this after already infering
  # ccode, time, and period, if needed
  if (is.null(x)) {
    x <- setdiff(colnames(data), c(ccode, time))
  }

  # Create missingness logical vector
  data[, "missing_value"] <- !stats::complete.cases(data[, x, drop = FALSE])
  data <- data[, c(ccode, time, "missing_value")]

  if (statelist=="none") {
    if (!is.factor(data[, ccode])) data[, ccode] <- as.factor(data[, ccode])
    ccode_range <- unique(data[, ccode])
    time_range  <- seq.Date(from = min(data[, time]),
                            to   = max(data[, time]),
                            by   = period
    )
    full_mat <- expand.grid(ccode_range, time_range)
    colnames(full_mat) <- c(ccode, time)

    full_mat$independent <- NA

    full_mat <- dplyr::left_join(full_mat, data, by = c(ccode, time))
    full_mat$status <- NA
    full_mat$status[full_mat$missing_value==TRUE]  <- "Missing values"
    full_mat$status[full_mat$missing_value==FALSE] <- "Complete"
    full_mat$status[is.na(full_mat$missing_value)] <- "No observation"
    stopifnot(!any(is.na(full_mat$status)))
    full_mat$status <- factor(full_mat$status, levels = c("Complete", "Missing values", "No observation"))

  } else {

    ccname <- ifelse(statelist=="GW", "gwcode", "cowcode")
    ind_states <- state_panel(min(data[, time]), max(data[, time]), by = period,
                              useGW = (statelist=="GW"), partial = partial)
    if (period=="year") {
      if (partial=="exact") {
        ind_states$date <- as.Date(paste0(ind_states$year,
                                          unique(substr(data[, time], 5, 11))
                                          ))
      } else {
        ind_states$date <- as.Date(paste0(ind_states$year, "-01-01"))
      }
      ind_states$year <- NULL
    }
    colnames(ind_states)  <- c(ccode, time)
    ind_states$independent <- 1

    full_mat <- dplyr::full_join(ind_states, data, by = c(ccode, time))

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

  # Arrange
  full_mat <- full_mat[order(full_mat[[ccode]], full_mat[[time]]), ]

  # keep track of relevant settings
  attr(full_mat, "ccode")     <- ccode
  attr(full_mat, "time")      <- time
  attr(full_mat, "statelist") <- statelist
  attr(full_mat, "period")    <- period
  attr(full_mat, "partial")   <- partial

  full_mat
}


#' Temporary helper function to warn about argument order change
#'
#' @param data data.frame
#' @param x string
#' @keywords internal
.warner <- function(data, x) {
  if (inherits(x, "data.frame") & class(data)[1]=="character") {
    warning("The order of the 'data' and 'x' arguments has switched, please adjust code accordingly.\nplot_missing(data, x, ...)\nmissing_info(data, x, ...)")
    return(list(data = x, x = data))
  }
  list(data = data, x = x)
}


id_ccode_column <- function(x) {
  idx <- c("gwcode", "cowcode") %in% x
  if (!any(idx)) {
    stop("Please specify the \"ccode\" argument")
  }
  if (all(idx)) {
    warning("Found both \"gwcode\" and \"cowcode\" columns in data, using \"gwcode\".")
    ccode <- "gwcode"
  }
  if (xor(idx[1], idx[2])) {
    ccode <- c("gwcode", "cowcode")[idx]
  }
  ccode
}

id_time_column <- function(x) {
  idx <- c("year", "date") %in% x
  if (!any(idx)) {
    stop("Please specify the \"time\" argument")
  }
  if (all(idx)) {
    warning("Found both \"date\" and \"year\" columns in data, using \"year\".")
    time <- "year"
  }
  if (xor(idx[1], idx[2])) {
    time <- c("year", "date")[idx]
  }
  time
}
