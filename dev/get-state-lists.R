library("dplyr")
library("readr")
library("lubridate")

gwstates <- readr::read_delim("http://privatewww.essex.ac.uk/~ksg/data/iisystem.dat",
                              delim = "\t", col_names = c("gwcode", "iso3c", "country_name", "start", "end"),
                              col_types = cols(gwcode = col_integer(), iso3c = col_character(), country_name = col_character(),
                                               start = col_date(format = "%d:%m:%Y"), end = col_date(format = "%d:%m:%Y")))

gwmicrostates <- readr::read_delim("http://privatewww.essex.ac.uk/~ksg/data/microstatessystem.dat",
                                   delim = "\t", col_names = c("gwcode", "iso3c", "country_name", "start", "end"),
                                   col_types = cols(gwcode = col_integer(), iso3c = col_character(), country_name = col_character(),
                                                    start = col_date(format = "%d:%m:%Y"), end = col_date(format = "%d:%m:%Y")))

gwstates$microstate <- FALSE
gwmicrostates$microstate <- TRUE

gwstates <- dplyr::bind_rows(gwstates, gwmicrostates)
gwstates$end[gwstates$end==max(gwstates$end)] <- as.Date("2017-12-31")

# Fix encoding issue for countries like Cote d'Ivoire
Encoding(gwstates$country_name) <- "latin1"
gwstates$country_name <- enc2utf8(gwstates$country_name)

gwstates <- as.data.frame(gwstates)
save(gwstates, file = "data/gwstates.rda")


cowstates <- readr::read_csv("http://www.correlatesofwar.org/data-sets/state-system-membership/states2016/at_download/file")

cowstates$start <- with(cowstates, as.Date(paste(styear, stmonth, stday, sep = "-")))
cowstates$end   <- with(cowstates, as.Date(paste(endyear, endmonth, endday, sep = "-")))

cowstates <- cowstates %>%
  rename(cow3c = stateabb, cowcode = ccode, country_name = statenme) %>%
  select(cowcode, cow3c, country_name, start, end)

Encoding(cowstates$country_name) <- "UTF-8"

cowstates <- as.data.frame(cowstates)


save(cowstates, file = "data/cowstates.rda")
