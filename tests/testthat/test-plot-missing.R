library("states")
library("ggplot2")

context("`plot_missing`")

cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$year <- as.integer(substr(as.character(cy$date), 1, 4))

cy$myvar <- rnorm(nrow(cy))
cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA
cy$date <- as.Date(paste0(cy$year, "-06-30"))

test_that("plot_missing accepts all input options", {

  expect_type(
    plot_missing("myvar", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "none"),
    "list")

  expect_type(
    plot_missing("myvar", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "GW"),
    "list")

  expect_type(
    plot_missing("myvar", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "COW"),
    "list")

  # not a valid statelist argument
  expect_error(
    plot_missing("myvar", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "Foo")
    )
})

test_that("mssng_mat throws errors for missing ID values", {

  expect_error({
    cy2 <- cy
    cy2$gwcode[1] <- NA
    mm <- mssng_mat("myvar", data = cy2, space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })

  expect_error({
    cy2 <- cy
    cy2$date[1] <- NA
    mm <- mssng_mat("myvar", data = cy2, space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })
})
