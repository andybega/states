library("states")

context("`state_panel()`")

test_that("input validation identifies errors", {
  expect_error(
    state_panel(NA, "1992-01-01", by = "day"),
    "Could not convert"
  )
  expect_error(
    state_panel("1991-01-01", "1992-01-01", by = "week"),
    "Only 'year', "
  )
  expect_error(
    state_panel("1991-01-01", "1992-01-01", partial = "middle"),
    "Only 'exact'"
  )
})

test_that("state_panel() works at all time resolutions", {
  expect_s3_class(
    state_panel("1991-01-01", "1992-01-01", by = "day"),
    "data.frame"
    )

  expect_s3_class(
    state_panel("1991-01-01", "1995-01-01", by = "month"),
    "data.frame"
  )

  expect_s3_class(
    state_panel("1991-01-01", "2001-01-01", by = "year"),
    "data.frame"
  )
})

test_that("correct columns are returned", {
  expect_equal(
    names(state_panel("1991-01-01", "2001-01-01", by = "year", partial = "exact")),
    c("gwcode", "date")
  )

  expect_equal(
    names(state_panel("1991-01-01", "2001-01-01", by = "year", partial = "any")),
    c("gwcode", "date")
  )
})


test_that("partial 'any' works at all time resolutions", {
  expect_error(state_panel("1991-01-01", "1992-01-01", by = "day", partial = "any"),
               NA)

  expect_error(state_panel("1991-01-01", "1992-01-01", by = "month", partial = "any"),
               NA)

  expect_error(state_panel("1991-01-01", "1992-01-01", by = "year", partial = "any"),
               NA)
})

# end date modification is done so that countries beyond the 'official' data
# end date are still included
test_that("end date is updated", {
  foo <- state_panel("2015-01-01", "2018-01-01", by = "year", partial = "any")
  expect_true(substr(max(foo$date), 1, 4)=="2018")
})

#
# test_that("state_panel() works with implicit time resolutions", {
#
# })
#
#
# context("`detect_date_format()`")
#
# test_that("date format is parsed correctly", {
#   expect_equal(detect_date_format("2017-05-01"), "ymd")
#   expect_error(detect_date_format("2017-05-011"))
#
#   expect_equal(detect_date_format("2017-05"), "ym")
#   expect_error(detect_date_format("2017-055"))
#
#   expect_equal(detect_date_format("2017"), "y")
#   expect_equal(detect_date_format(2017), "y")
#   expect_error(detect_date_format("20177"))
# })


