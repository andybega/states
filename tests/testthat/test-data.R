
test_that("gwstates is a plain data.frame", {
  data(gwstates)
  expect_identical(class(gwstates), "data.frame")

  # no readr attribute
  expect_null(attr(gwstates, "spec"))
})



test_that("cowstates is a plain data.frame", {
  data(cowstates)
  expect_identical(class(cowstates), "data.frame")

  # no readr attribute
  expect_null(attr(cowstates, "spec"))
})
