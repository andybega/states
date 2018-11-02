library("states")

context("Test `sfind()`")

test_that("sfind treats character numeric input as numeric", {

  expect_equal(nrow(sfind(260, list = "GW")), 1L)
  expect_equal(nrow(sfind("260", list = "GW")), 1L)

  expect_equal(
    sfind("260", list = "GW"),
    sfind(260, list = "GW")
    )

})

test_that("query capitalization does not matter", {

  expect_equal(
    sfind("Vietnam", list = "GW"),
    sfind("vietnam", list = "GW")
  )

})
