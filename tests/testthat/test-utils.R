
test_that("implied time periods are identified correctly", {

  expect_equal(id_period(2006), "year")
  expect_equal(id_period("2006"), "year")

  expect_equal(id_period("2006-6"), "month")
  expect_equal(id_period("2006-06"), "month")

  expect_equal(id_period("2006-06-01"), "day")
  expect_equal(id_period("2006-6-01"), "day")
  expect_equal(id_period("2006-6-1"), "day")

})

test_that("id_period throws an error if cannot ID period", {

  expect_error(id_period("a"), "implied period")

})

test_that("start and end inputs are correctly parsed as dates", {

  expect_error(parse_date(2006), NA)
  expect_error(parse_date("2006"), NA)
  expect_error(parse_date("2006-6"), NA)
  expect_error(parse_date("2006-06"), NA)
  expect_error(parse_date("2006-06-01"), NA)
  expect_error(parse_date("2006-6-01"), NA)
  expect_error(parse_date("2006-6-1"), NA)
  expect_error(parse_date(as.Date("2006-06-01")), NA)

  expect_error(parse_date(NA))

  expect_error(parse_date(2))
  expect_error(parse_date(10000))

  expect_error(parse_date("a"))
  expect_error(parse_date("aaaa"))

})

test_that("parse_date throws an error for non-matching implied periods", {

  expect_error(
    parse_date(c("2006", "2006-01")),
    "multiple implied"
  )

})
