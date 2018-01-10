#' Compute matrix of missing status for state panel
#'
#' @param x Variable names(s), e.g. "x" or c("x1", "x2").
#' @param data State panel data frame
#' @param space Name of state identifier
#' @param time Name of time identifier
#' @param time_unit Temporal resolution character string, e.g. "year" or "month".
#'     See details in \code{\link[base]{seq.Date}}.
#' @param statelist Check not only missing values, but presence or absence of
#'     observations against a list of independent states?
#'
#' @importFrom dplyr left_join
mssng_mat_base <- function(x, data, space, time, time_unit, statelist = "none") {
  if (!is.factor(data[, space])) data[, space] <- as.factor(data[, space])
  space_range <- unique(data[, space])
  time_range  <- seq.Date(from = min(data[, time]),
                          to   = max(data[, time]),
                          by   = time_unit
  )
  full_mat <- expand.grid(space_range, time_range)
  colnames(full_mat) <- c(space, time)

  data <- data[, c(space, time, x)]

  full_mat <- dplyr::left_join(full_mat, data, by = c(space, time))
  full_mat$.mssng[full_mat$.mssng==TRUE]  <- "Missing values"
  full_mat$.mssng[full_mat$.mssng==FALSE] <- "Complete"
  full_mat$.mssng[is.na(full_mat$.mssng)] <- "No observation"
  full_mat$.mssng <- factor(full_mat$.mssng, levels = c("Complete", "Missing values", "No observation"))

  if (statelist %in% c("GW", "COW")) {
    # set ss type GW or COW
    ccname <- ifelse(statelist=="GW", "gwcode", "cowcode")
    target <- state_panel(min(full_mat[, time]), max(full_mat[, time]), by = time_unit, useGW = (statelist=="GW"))
    target$id <- NULL
    target$.statelist <- 1
    target[, ccname]  <- as.integer(as.character(target[, ccname]))
    colnames(target)  <- c(space, time, ".statelist")

    full_mat[, space] <- as.integer(as.character(full_mat[, space]))
    full_mat          <- dplyr::left_join(full_mat, target, by = c(space, time))

    full_mat$.statelist <- ifelse(is.na(full_mat$.statelist), "non-independent", "independent state")
    lvls        <- as.vector(outer(c("Complete", "Missing values", "No observation"), c("independent state", "non-independent"), paste, sep = ", "))
    full_mat$.z <- paste(full_mat$.mssng, full_mat$.statelist, sep = ", ")
    full_mat$.z <- factor(full_mat$.z, levels = lvls)

    full_mat[, space] <- factor(full_mat[, space], levels = rev(sort(unique(full_mat[, space]))))
  } else {
    full_mat$.z <- full_mat$.mssng
  }
  full_mat
}

#' Compute missing status for state panel
#'
#' @param x Variable names(s), e.g. "x" or c("x1", "x2").
#' @param data State panel data frame
#' @param space Name of state identifier
#' @param time Name of time identifier
#' @param time_unit Temporal resolution character string, e.g. "year" or "month".
#'     See details in \code{\link[base]{seq.Date}}.
#' @param statelist Check not only missing values, but presence or absence of
#'     observations against a list of independent states?
#'
#' @export
#' @importFrom stats complete.cases
mssng_mat <- function(x, data, space, time, time_unit, statelist = "none") {
  if (any(is.na(data[, space]))) stop(paste0("Space identifier '", space, "' contains missing values."))
  if (any(is.na(data[, time]))) stop(paste0("Space identifier '", time, "' contains missing values."))

  # Create missingness logical vector
  data[, ".mssng"] <- !stats::complete.cases(data[, x])
  data <- data[, c(space, time, ".mssng")]

  out <- mssng_mat_base(".mssng", data, space, time, time_unit, statelist)
  out
}

#' Visualize missing status for state panel
#'
#' @param x Variable names(s), e.g. "x" or c("x1", "x2"). To check all variables
#'      in a data frame use something like.
#' @param data State panel data frame
#' @param space Name of state identifier
#' @param time Name of time identifier
#' @param time_unit Temporal resolution character string, e.g. "year" or "month".
#'     See details in \code{\link[base]{seq.Date}}.
#' @param statelist Check not only missing values, but presence or absence of
#'     observations against a list of independent states?
#'
#' @examples
#' # To check all variables:
#' # plot_missing(setdiff(colnames(df), "space", "time"), ...)
#'
#' @importFrom grDevices hcl
#' @export
plot_missing <- function(x, data, space, time, time_unit,
                         statelist = c("none", "GW", "COW")) {
  if (!statelist %in% c("none", "GW", "COW")) {
    stop(sprintf("'%s' is not a valid option for 'statelist', use 'none', 'GW', or 'COW'",
         statelist))
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 needed for this function to work. Please install it.",
         call. = FALSE)
  }

  mm <- mssng_mat(x, data, space, time, time_unit, statelist)

  p <- ggplot2::ggplot(mm, ggplot2::aes_string(x = time, y = space, fill = ".z")) +
    ggplot2::geom_tile() +
    ggplot2::scale_x_date(expand = c(0, 0))

  if (statelist %in% c("GW", "COW")) {
    checkSS_flag <- TRUE
    mm$.fill <- mm$.z
    fill_values <- c("Complete, independent state" = hcl(195, 100, 65), "Complete, non-independent" = hcl(15, 100, 20),
                     "Missing values, independent state"  = hcl(15, 100, 65), "Missing values, non-independent"  = hcl(15, 100, 45),
                     "No observation, independent state"   = hcl(15, 100, 85), "No observation, non-independent"   = hcl(15, 0, 97))
  } else {
    mm$.fill <- mm$.z
    fill_values <-  c("Complete"         = grDevices::hcl(195, l=65, c=100),
                      "Missing values"   = grDevices::hcl(15, l=65, c=100),
                      "No observation"   = grDevices::hcl(15, l=97, c=0))
  }

  p <- ggplot2::ggplot(mm, ggplot2::aes_string(x = time, y = space, fill = ".fill")) +
    ggplot2::geom_tile() +
    ggplot2::scale_x_date(expand=c(0, 0)) +
    ggplot2::scale_fill_manual("", drop = FALSE, values = fill_values) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = 2)) +
    ggplot2::theme(legend.position = "bottom")
  p
}



