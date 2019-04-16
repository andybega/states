
context("country_names() and prettyc()")

test_that("prettyc() works", {

  xin <- c("Congo, Democratic Republic of (Zaire)",
           "Vietnam (Annam/Cochin China/Tonkin)",
           "Yemen, People's Republic of")
  xout <- c("DR Congo",
            "Vietnam",
            "South Yemen")
  expect_equal(prettyc(xin), xout)

})
