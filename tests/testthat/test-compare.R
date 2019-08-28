
# df2 has all countries in 2018 but some values in x1 are missing
df1 <- state_panel(2018, 2018, partial = "any")
df1$year <- as.integer(substr(df1$date, 1, 4))
df1$date <- NULL
df1$x1 <- round(runif(nrow(df1))*5)
df1$x1[sample.int(nrow(df1), size = 20, replace = FALSE)] <- NA

# df2 is missing some countries and also has missing values in x2
df2 <- state_panel(2018, 2018, partial = "any")
df2 <- df2[sample.int(nrow(df2), size = 150), ]
df2$year <- as.integer(substr(df2$date, 1, 4))
df2$date <- NULL
df2$x2 <- round(runif(nrow(df2))*5)
df2$x2[sample.int(nrow(df2), size = 20, replace = FALSE)] <- NA

test_that("merge with different column names works", {

  expect_error(out <- compare(df1, df2), NA)

})
