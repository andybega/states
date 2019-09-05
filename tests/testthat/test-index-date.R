
x <- paste(2001:2012, 1:12, seq(15, by = 1, length.out = 12), sep = "-")
x <- as.Date(x, format = "%Y-%m-%d")

test_that("day periods are correctly indexed", {

  expect_equal(
    index_date(x, period = "day"),
    x
  )

})

test_that("year periods are correctly indexed", {

  expect_equal(
    index_date(x, period = "year"),
    as.Date(paste0(2001:2012, "-01-01"))
  )

})

test_that("month periods are correctly indexed", {

  expect_equal(
    index_date(x, period = "month"),
    as.Date(paste0(2001:2012, "-", 1:12, "-01"), format = "%Y-%m-%d")
  )

})

test_that("error is thrown for new periods", {

  expect_error(index_date(x, period = "week"), "week")

})
