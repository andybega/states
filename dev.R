

library("dplyr")
library("readr")


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


cowstates <- readr::read_csv("http://www.correlatesofwar.org/data-sets/state-system-membership/states2016/at_download/file")

cowstates$start <- with(cowstates, as.Date(paste(styear, stmonth, stday, sep = "-")))
cowstates$end   <- with(cowstates, as.Date(paste(endyear, endmonth, endday, sep = "-")))

cowstates <- cowstates %>%
  rename(cow3c = stateabb, cowcode = ccode, country_name = statenme) %>%
  select(cowcode, cow3c, country_name, start, end)

save(gwstates, file = "data/gwstates.rda")
save(cowstates, file = "data/cowstates.rda")


# Package development -----------------------------------------------------
#
#   keep track in news.md
#

library("devtools")

#devtools::use_testthat()

if (!requireNamespace("pkg", quietly = TRUE)) {
  stop("Pkg needed for this function to work. Please install it.",
       call. = FALSE)
}


# Check local
devtools::load_all()
devtools::test()
devtools::document()
devtools::check()


# Package release ---------------------------------------------------------

library("devtools")

#   Update NEWS
#
#   Update date and version in DESCRIPTION:
#     [major][minor][patch][dev]
#       - major: not backwards compatible
#       - minor: feature enhancements
#       - patch: fixes bugs
#       - dev (9000): working version

devtools::check()
devtools::build()

build_win(version = "R-release")
build_win(version = "R-devel")

# commit to git for travis
# https://travis-ci.org

#   once emails are in and travis is done:
#
#   Update cran-comments.md

R.Version()$version.string

devtools::release()

# update local install
desc <- readLines("DESCRIPTION")
vers <- desc[grep("Version", desc)]
vers <- stringr::str_extract(vers, "[0-9\\.]+")
devtools::install_url(paste0("file://", getwd(), "/../states_", vers, ".tar.gz"))
