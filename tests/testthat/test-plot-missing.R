
test_that("id_space_columns returns correct output", {

  expect_equal(
    id_ccode_column(c("gwcode", "x")),
    "gwcode"
  )

  expect_equal(
    id_ccode_column(c("cowcode", "x")),
    "cowcode"
  )

  expect_error(
    id_ccode_column(c("ccode", "x")),
    "Please specify"
  )

  expect_warning(
    id_ccode_column(c("gwcode", "cowcode", "x")),
    "Found both"
  )

})

test_that("id_time_columns returns correct output", {

  expect_equal(
    id_time_column(c("year", "x")),
    "year"
  )

  expect_equal(
    id_time_column(c("date", "x")),
    "date"
  )

  expect_error(
    id_time_column(c("YEAR", "x")),
    "Please specify"
  )

  expect_warning(
    id_time_column(c("year", "date", "x")),
    "Found both"
  )

})



cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$myvar <- rnorm(nrow(cy))
cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA


test_that("plot missing works with country-year data", {

  expect_error(
    plot_missing(cy),
    NA
  )

})

cy$date <- as.Date(paste0(cy$year, "-01-01"))
cy$year <- NULL

test_that("plot_missing accepts all input options", {

  expect_type(
    plot_missing(data = cy, "myvar", ccode = "gwcode", time = "date",
                 period = "year", statelist = "none"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", ccode = "gwcode", time = "date",
                 period = "year", statelist = "GW"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", ccode = "gwcode", time = "date",
                 period = "year", statelist = "COW"),
    "list")

  # not a valid statelist argument
  expect_error(
    plot_missing(data = cy, "myvar", ccode = "gwcode", time = "date",
                 period = "year", statelist = "Foo")
    )
})

test_that("mssng_mat throws errors for missing ID values", {

  expect_error({
    cy2 <- cy
    cy2$gwcode[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", ccode = "gwcode", time = "date",
                    period = "year", statelist = "GW")
  })

  expect_error({
    cy2 <- cy
    cy2$date[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", ccode = "gwcode", time = "date",
                    period = "year", statelist = "GW")
  })
})

test_that("plot_missing works with tibbles", {
  # if the data is the same, plot will be the same too
  expect_equal(
    missing_info(cy, "myvar", "gwcode", "date", "year", "GW"),
    missing_info(dplyr::as_tibble(cy), "myvar", "gwcode", "date", "year", "GW")
  )
})




test_that("missing_info input checks", {

  cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                    useGW = TRUE)
  cy$myvar <- rnorm(nrow(cy))
  cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA
  cy$date <- as.Date(paste0(cy$year, "-01-01"))

  expect_error(missing_info(cy, "myvar", "gwcode", "date", "year", "GW"),
               NA)

  cy2 <- cy
  cy2$gwcode[1] <- NA
  expect_error(
    missing_info(cy2, "myvar", "gwcode", "date", "year", "GW"),
    "cannot contain"
  )

  cy2 <- cy
  cy2$date[1] <- NA
  expect_error(
    missing_info(
      cy2, "myvar", "gwcode", "date", "year", "GW"),
    "cannot contain"
  )

  cy2 <- cy
  cy2$date <- as.integer(cy2$date)
  expect_error(
    missing_info(cy2, "myvar", "gwcode", "date", "year", "GW"),
    "Can't convert"
  )

  expect_error(
    missing_info(cy, "myvar", "gwcode", "date", "year", "G&W"),
    "is not a valid option"
  )

})

test_that("auto input recognition works", {
  cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                    useGW = TRUE)
  cy$myvar <- rnorm(nrow(cy))
  cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA
  cy$date <- as.Date(paste0(cy$year, "-01-01"))

  expect_error(missing_info(cy, "myvar", ccode = "gwcode", time = "date", period = "year", statelist = "GW"), NA)
  expect_error(missing_info(cy, "myvar", ccode = NULL, time = "date", period = "year", statelist = "GW"), NA)
  cy$cowcode <- cy$gwcode
  expect_warning(missing_info(cy, "myvar", ccode = NULL, time = "date", period = "year", statelist = "GW"), "Found both")
  cy$gwcode <- NULL
  expect_error(missing_info(cy, "myvar", ccode = NULL, time = "date", period = "year", statelist = "GW"), NA)


  expect_warning(
    missing_info(cy, statelist = "GW"),
    "Found both \"date"
  )
  expect_warning(
    plot_missing(cy, statelist = "GW"),
    "Found both \"date"
  )
})

test_that("exact date in put is correctly handled", {

  data("polity")
  # get data that reaches to 1816. Argentina became independent on 1816-07-09
  # in GW list
  polity <- head(polity, 17)

  polity$date <- as.Date(paste0(polity$year, "-07-01"))
  expect_error(
    mm <- missing_info(polity, x = "polity", ccode = "ccode",
                       time = "date", period = "year",
                       statelist = "GW"),
    NA
  )
  expect_false(160 %in% mm$ccode)

  polity$date <- as.Date(paste0(polity$year, "-07-10"))
  expect_error(
    mm <- missing_info(polity, x = "polity", ccode = "ccode",
                       time = "date", period = "year",
                       statelist = "GW"),
    NA
  )
  expect_true(160 %in% mm$ccode)

})
