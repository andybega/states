
test_that("state_panel_date returns correct cases with partial options", {

  # In 2006, Montenegro (341) started on 3 June, Serbia (340) on 5 June; good
  # separation point
  sdate = as.Date("2006-06-04")
  edate = as.Date("2006-12-31")

  out <- state_panel_date(start = sdate, end = edate, by = "year",
                          partial = "exact", useGW = TRUE)
  expect_true(341 %in% out$ccode)
  expect_false(340 %in% out$ccode)

  out <- state_panel_date(start = sdate, end = edate, by = "year",
                          partial = "any", useGW = TRUE)
  expect_true(341 %in% out$ccode)
  expect_true(340 %in% out$ccode)

  out <- state_panel_date(start = sdate, end = edate, by = "year",
                          partial = "first", useGW = TRUE)
  expect_false(341 %in% out$ccode)
  expect_false(340 %in% out$ccode)

  expect_error(
    out <- state_panel_date(start = sdate, end = edate, by = "year",
                            partial = "last", useGW = TRUE),
    NA
  )
  expect_true(341 %in% out$ccode)
  expect_true(340 %in% out$ccode)

})

test_that("state_panel_date partial = last option for sub-year by works", {

  # In 2006, Montenegro (341) started on 3 June, Serbia (340) on 5 June; good
  # separation point
  sdate = as.Date("2006-06-04")
  edate = as.Date("2006-12-31")

  expect_error(
    out <- state_panel_date(start = sdate, end = edate, by = "month",
                            partial = "last", useGW = TRUE),
    "Not implemented")

})

test_that("input validation identifies errors", {
  expect_error(
    state_panel(NA, "1992-01-01", by = "day"),
    "implied period"
  )
  expect_error(
    state_panel("1991-01-01", "1992-01-01", by = "week"),
    "Only 'year'"
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

test_that("date shortcuts work", {

  expect_error(
    state_panel(2006, 2006),
    NA
  )

  expect_error(
    state_panel("2006", "2006"),
    NA
  )

  expect_error(
    state_panel("2006-06", "2006-06"),
    NA
  )

})

test_that("date shortcuts with inconsistent periods are rejected", {

  expect_error(
    state_panel("2011-01-01", "2011"),
    "multiple implied"
    )

})


