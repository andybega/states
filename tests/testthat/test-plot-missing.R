
cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$myvar <- rnorm(nrow(cy))
cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA

test_that("plot_missing accepts all input options", {

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 period = "year", statelist = "none"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 period = "year", statelist = "GW"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 period = "year", statelist = "COW"),
    "list")

  # not a valid statelist argument
  expect_error(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 period = "year", statelist = "Foo")
    )
})

test_that("mssng_mat throws errors for missing ID values", {

  expect_error({
    cy2 <- cy
    cy2$gwcode[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", space = "gwcode", time = "date",
                    period = "year", statelist = "GW")
  })

  expect_error({
    cy2 <- cy
    cy2$date[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", space = "gwcode", time = "date",
                    period = "year", statelist = "GW")
  })
})

test_that("plot_missing works with tibbles", {
  expect_equal(
    plot_missing(cy, "myvar", "gwcode", "date", "year", "GW"),
    plot_missing(dplyr::as_tibble(cy), "myvar", "gwcode", "date", "year", "GW")
  )

  expect_equal(
    missing_info(cy, "myvar", "gwcode", "date", "year", "GW"),
    missing_info(dplyr::as_tibble(cy), "myvar", "gwcode", "date", "year", "GW")
  )

})


context("missing_info()")

test_that("missing_info input checks", {

  cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                    useGW = TRUE)
  cy$myvar <- rnorm(nrow(cy))
  cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA

  expect_error(missing_info(cy, "myvar", "gwcode", "date", "year", "GW"),
               NA)

  cy2 <- cy
  cy2$gwcode[1] <- NA
  expect_error(missing_info(cy2, "myvar", "gwcode", "date", "year", "GW"),
               "Space identifier")

  cy2 <- cy
  cy2$date[1] <- NA
  expect_error(missing_info(cy2, "myvar", "gwcode", "date", "year", "GW"),
               "Time identifier")

  cy2 <- cy
  cy2$date <- as.integer(cy2$date)
  expect_error(missing_info(cy2, "myvar", "gwcode", "date", "year", "GW"),
               "Time identifier")

  expect_error(missing_info(cy, "myvar", "gwcode", "date", "year", "G&W"),
               "Valid choices")

})

test_that("auto input recognition works", {
  cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                    useGW = TRUE)
  cy$myvar <- rnorm(nrow(cy))
  cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA

  expect_error(missing_info(cy, "myvar", space = "gwcode", time = "date", period = "year", statelist = "GW"), NA)
  expect_error(missing_info(cy, "myvar", space = NULL, time = "date", period = "year", statelist = "GW"), NA)
  cy$cowcode <- cy$gwcode
  expect_warning(missing_info(cy, "myvar", space = NULL, time = "date", period = "year", statelist = "GW"), "Found both")
  cy$gwcode <- NULL
  expect_error(missing_info(cy, "myvar", space = NULL, time = "date", period = "year", statelist = "GW"), NA)


  expect_error(missing_info(cy, statelist = "GW"), NA)
  expect_error(plot_missing(cy, statelist = "GW"), NA)
})
