#
#
# test_that("Year sequences handle position correctly", {
#   expect_equal(
#     seq_period("2015-01-01", "2017-01-01", period = "year", position = "first"),
#     as.Date(c("2015-01-01", "2016-01-01", "2017-01-01"))
#   )
#
#   expect_equal(
#     seq_period("2015-01-01", "2017-01-01", period = "year", position = "middle"),
#     as.Date(c("2015-06-30", "2016-06-30", "2017-06-30"))
#   )
#
#   expect_equal(
#     seq_period("2015-01-01", "2017-01-01", period = "year", position = "last"),
#     as.Date(c("2015-12-31", "2016-12-31", "2017-12-31"))
#   )
#
#   expect_equal(
#     seq_period("2015-07-01", "2017-07-01", period = "year", position = "identity"),
#     as.Date(c("2015-07-01", "2016-07-01", "2017-07-01"))
#   )
# })
#
# test_that("Month sequences handle position correctly", {
#   expect_equal(
#     seq_period("2015-01-10", "2015-03-10", period = "month", position = "first"),
#     as.Date(c("2015-01-01", "2015-02-01", "2015-03-01"))
#   )
#
#   expect_equal(
#     seq_period("2015-01-10", "2015-03-10", period = "month", position = "middle"),
#     as.Date(c("2015-01-15", "2015-02-15", "2015-03-15"))
#   )
#
#   expect_equal(
#     seq_period("2015-01-10", "2015-03-10", period = "month", position = "last"),
#     as.Date(c("2015-01-31", "2015-02-28", "2015-03-31"))
#   )
#
#   expect_equal(
#     seq_period("2015-01-10", "2015-03-10", period = "month", position = "identity"),
#     as.Date(c("2015-01-10", "2015-02-10", "2015-03-10"))
#   )
# })
#
#
#
#
#
#
