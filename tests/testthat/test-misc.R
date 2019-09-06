

test_that("id_date_sequence works", {
  seq1 <- seq(as.Date("2018-01-01"), as.Date("2025-01-01"), by = "year")
  df1 <- data.frame(seq1)
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

