library("dplyr")
library("readr")
library("lubridate")
library("usethis")

cow_url <- "http://www.correlatesofwar.org/data-sets/state-system-membership/states2016/at_download/file"

cowstates <- readr::read_csv(cow_url)

cowstates$start <- with(cowstates, as.Date(paste(styear, stmonth, stday, sep = "-")))
cowstates$end   <- with(cowstates, as.Date(paste(endyear, endmonth, endday, sep = "-")))

cowstates$end[cowstates$end==max(cowstates$end)] <- as.Date("9999-12-31")

cowstates <- cowstates %>%
  rename(cow3c = stateabb, cowcode = ccode, country_name = statenme) %>%
  select(cowcode, cow3c, country_name, start, end)

Encoding(cowstates$country_name) <- "UTF-8"

table(stringi::stri_enc_mark(gwstates$country_name))

cowstates <- as.data.frame(cowstates)

usethis::use_data(cowstates, overwrite = TRUE)
