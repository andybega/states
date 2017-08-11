library("states")
library("WDI")
library("countrycode")
library("ggplot2")

context("`plot_missing`")

cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$year <- as.integer(substr(as.character(cy$date), 1, 4))

xdf <- WDI(indicator = c("NY.GDP.PCAP.KD", "SP.POP.TOTL"), start = 1980, end = 2015)
xdf$gwcode <- countrycode(xdf$iso2c, "iso2c", "cown")
xdf$year <- as.integer(xdf$year)

cy <- merge(cy, xdf, by = c("gwcode", "year"))
cy <- cy[!is.na(cy$gwcode), ]
cy$date <- as.Date(paste0(cy$year, "-06-30"))

test_that("plot_missing accepts all input options", {

  expect_type(
    plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "none"),
    "list")

  expect_type(
    plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "GW"),
    "list")

  expect_type(
    plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "COW"),
    "list")

  # not a valid statelist argument
  expect_error(
    plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
                 time_unit = "year", statelist = "Foo")
    )
})

test_that("mssng_mat throws errors for missing ID values", {

  expect_error({
    cy2 <- cy
    cy2$gwcode[1] <- NA
    mm <- mssng_mat("NY.GDP.PCAP.KD", data = cy2, space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })

  expect_error({
    cy2 <- cy
    cy2$date[1] <- NA
    mm <- mssng_mat("NY.GDP.PCAP.KD", data = cy2, space = "gwcode", time = "date",
                    time_unit = "year", statelist = "GW")
  })
})
