#
#   Tests for plot_missing and associated code
#


library("WDI")
library("states")
library("countrycode")
library("dplyr")
library("ggplot2")

cy <- state_panel(as.Date("1980-06-30"), as.Date("2015-06-30"), by = "year",
                  useGW = TRUE)
cy$year <- as.integer(substr(as.character(cy$date), 1, 4))

xdf <- WDI(indicator = c("NY.GDP.PCAP.KD", "SP.POP.TOTL"), start = 1980, end = 2015)
xdf$gwcode <- countrycode(xdf$iso2c, "iso2c", "cown")
xdf$year <- as.integer(xdf$year)

cy <- full_join(cy, xdf, by = c("gwcode", "year")) %>%
  dplyr::filter(!is.na(gwcode)) %>%
  mutate(date = as.Date(paste0(year, "-06-30")))

mm <- mssng_mat("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
                time_unit = "year", statelist = "GW")

plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
             time_unit = "year", statelist = "none")
plot_missing("NY.GDP.PCAP.KD", data = cy, space = "gwcode", time = "date",
             time_unit = "year", statelist = "GW")

cy2 <- cy
cy2$gwcode[1] <- NA
mm <- mssng_mat("NY.GDP.PCAP.KD", data = cy2, space = "gwcode", time = "date",
                time_unit = "year", statelist = "GW")

cy2 <- cy
cy2$date[1] <- NA
mm <- mssng_mat("NY.GDP.PCAP.KD", data = cy2, space = "gwcode", time = "date",
                time_unit = "year", statelist = "GW")

# old test code

test_df <- data.frame(
  ccode=c(rep(1, 3), rep(2, 4)),
  year=c(rep(seq(2000, 2002), 2), 2003),
  x1=c(1,1,NA,1,NA,1,1)
)
test_df$year <- as.Date(paste0(test_df$year, "-06-15"))

#plot_missing(test_df, "ccode", "year", "x1", "year") + theme_bw()

#mssng_mat("x1", test_df, "ccode", "year", "year")
