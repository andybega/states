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
  rename(cowc = stateabb, cowcode = ccode, country_name = statenme) %>%
  select(cowcode, cowc, country_name, start, end)

Encoding(cowstates$country_name) <- "UTF-8"

table(stringi::stri_enc_mark(gwstates$country_name))

cowstates <- as.data.frame(cowstates)

# add microstate coding
data(gwstates)
micro <- gwstates[gwstates$microstate %in% TRUE, ]
cowstates$microstate = FALSE
cowstates$microstate[cowstates$cowcode %in% micro$gwcode] <- TRUE
cowstates$microstate[cowstates$country_name %in% micro$country_name] <- TRUE

# COW doesn't have South Ossetia and Abkhazia, so -2 on rows, otherwise should
# equal
stopifnot(
  nrow(cowstates[cowstates$microstate %in% TRUE, ])==(nrow(micro) - 2)
)


usethis::use_data(cowstates, overwrite = TRUE)
