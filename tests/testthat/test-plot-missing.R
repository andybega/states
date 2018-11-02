library("states")
library("ggplot2")
library("dplyr")

context("`plot_missing`")

cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$myvar <- rnorm(nrow(cy))
cy$myvar[sample(1:nrow(cy), nrow(cy)*.1, replace = FALSE)] <- NA

test_that("plot_missing accepts all input options", {

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 time_unit = "year", statelist = "none"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 time_unit = "year", statelist = "GW"),
    "list")

  expect_type(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 time_unit = "year", statelist = "COW"),
    "list")

  # not a valid statelist argument
  expect_error(
    plot_missing(data = cy, "myvar", space = "gwcode", time = "date",
                 time_unit = "year", statelist = "Foo")
    )
})

test_that("mssng_mat throws errors for missing ID values", {

  expect_error({
    cy2 <- cy
    cy2$gwcode[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })

  expect_error({
    cy2 <- cy
    cy2$date[1] <- NA
    mm <- mssng_mat(data = cy2, "myvar", space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })
})

test_that("plot_missing works with tibbles", {
  expect_equal(
    plot_missing(cy, "myvar", "gwcode", "date", "year", "GW"),
    plot_missing(as_tibble(cy), "myvar", "gwcode", "date", "year", "GW")
  )

  expect_equal(
    missing_info(cy, "myvar", "gwcode", "date", "year", "GW"),
    missing_info(as_tibble(cy), "myvar", "gwcode", "date", "year", "GW")
  )

})
