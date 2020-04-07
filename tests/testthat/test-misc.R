

test_that("id_date_sequence works", {
  seq1 <- seq(as.Date("2018-01-01"), as.Date("2025-01-01"), by = "year")
  df1 <- data.frame(date = seq1)
  df2 <- data.frame(date = seq1[-4])

  expect_error(df1$id <- id_date_sequence(df1$date, "year"), NA)
  expect_length(unique(df1$id), 1L)

  expect_error(df2$id <- id_date_sequence(df2$date, "year"), NA)
  expect_length(unique(df2$id), 2L)

  expect_error(df2$id <- id_date_sequence(df2$date, "year"), NA)
  expect_error(df2$id <- id_date_sequence(df2$date, "month"), NA)
  expect_error(df2$id <- id_date_sequence(df2$date, "week"), NA)
  expect_error(df2$id <- id_date_sequence(df2$date, "day"), NA)
  expect_error(df2$id <- id_date_sequence(df2$date, "foo"),
               "Did not recognize time period")
})

test_that("id_date_sequence works with integer year dates", {

  yr <- c(2002:2005, 2007:2010)
  expect_equal(
    id_date_sequence(yr),
    c(rep(1L, 4), rep(2L, 4))
  )

  # rejects years before G&W start and non-sensical years
  expect_error(id_date_sequence(1814))
  expect_error(id_date_sequence(10000))

  # but 9999 works
  expect_error(id_date_sequence(9999), NA)

})

