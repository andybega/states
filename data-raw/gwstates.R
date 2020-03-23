library("dplyr")
library("readr")
library("lubridate")
library("usethis")
library("stringr")

ksg_states_url <- "http://ksgleditsch.com/data/iisystem.dat"
ksg_microstates_url <- "http://ksgleditsch.com/data/microstatessystem.dat"

gwstates <- readr::read_delim(
  ksg_states_url,
  delim = "\t",
  col_names = c("gwcode", "gwc", "country_name", "start", "end"),
  col_types = cols(gwcode = col_integer(),
                   gwc = col_character(),
                   country_name = col_character(),
                   start = col_date(format = "%d:%m:%Y"),
                   end = col_date(format = "%d:%m:%Y")))

gwmicrostates <- readr::read_delim(
  ksg_microstates_url,
  delim = "\t",
  col_names = c("gwcode", "gwc", "country_name", "start", "end"),
  col_types = cols(gwcode = col_integer(),
                   gwc = col_character(),
                   country_name = col_character(),
                   start = col_date(format = "%d:%m:%Y"),
                   end = col_date(format = "%d:%m:%Y")))

gwstates$microstate <- FALSE
gwmicrostates$microstate <- TRUE

gwstates <- dplyr::bind_rows(gwstates, gwmicrostates)
gwstates$end[gwstates$end==max(gwstates$end)] <- as.Date("9999-12-31")

# Fix encoding issue for countries like Cote d'Ivoire
Encoding(gwstates$country_name) <- "latin1"
gwstates$country_name <- enc2utf8(gwstates$country_name)

# Get rid of non-Ascii characters, this causes CRAN NOTEs
gwstates <- gwstates %>%
  mutate(country_name = str_replace(country_name, "ü", "u"),
         country_name = str_replace(country_name, "’", "'"),
         country_name = str_replace(country_name, "ã", "a"),
         country_name = str_replace(country_name, "é", "e"))
table(stringi::stri_enc_mark(gwstates$country_name))

gwstates <- as.data.frame(gwstates)

usethis::use_data(gwstates, overwrite = TRUE)



