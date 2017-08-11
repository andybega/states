library("states")

context("`state_panel()`")

test_that("state_panel() works at all time resolutions", {
  expect_s3_class(
    state_panel(as.Date("1991-01-01"), as.Date("1992-01-01"), by = "day"),
    "data.frame"
    )

  expect_s3_class(
    state_panel(as.Date("1991-01-01"), as.Date("1995-01-01"), by = "month"),
    "data.frame"
  )

  expect_s3_class(
    state_panel(as.Date("1991-01-01"), as.Date("2001-01-01"), by = "year"),
    "data.frame"
  )
})
