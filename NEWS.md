
# states 0.3.1.9000

Several small fixes. 

## Bug fixes

- Manually add a "states-packge" alias for the package doc since **roxygen2** does not do this by default anymore. 
- Switch from the deprecated `ggplot2::aes_string()` to `ggplot2::aes()` + the `.data` pronoun in `plot_missing()`. 
- Fix a **dplyr** join warning in `state_panel()` due to the new "relationship" argument.
- Update old URLs in README and other documentation.


# states 0.3.1

- Strip **readr** "spec" attribute from the _cowstates_ and _gwstates_ data. They are both now plain data frames with no attributes. (#22)
- Expand list of short country names in `prettyc()`, e.g. instead of "Belarus (Byelorussia)", just "Belarus". 
- Move to **testthat** 3rd edition (**3e**). 

## Bug fixes

- `all.equal()` in R 4.1.x (R-devel at this point) will check environments for equivalence as well. This breaks one test since 2e **testthat** relies on `all.equal()` for `expect_equal()`. Moving to testthat 3e fixes this bug. (#26)


# states 0.3.0

- Although the original COW state list does not distinguish micro-states, like the G&W list does, the `cowstates` data now has a microstates coding derived from the G&W coding (#24). This makes it easier, for example, to filter out micro-states from a state panel dataset. 
- In the gwstates and cowstates data, the "iso3c" columns have been renamed to "gwn" and "cown", as they are not in fact ISO 3-character country abbreviations (#19).
- plot_missing()'s "space" argument has been renamed "ccode". 
- id_date_sequence() now works with integer years, there is no need to convert them to Date class anymore (#20).

## Improved support for state_panel shortcuts

`state_panel()` has further improved support for input shortcuts (#3):

- Accepted formats for the "start" and "end" arguments now include 2006, "2006", "2000-06", and "2006-06-01". See `parse_date()` for details. 
- The implied time period is now also inferred from shortcut input when "by" is left at the new default of NULL. 
- The "partial" option has gained new "first" and "last" values that also support shortcut input. Previously a shortcut input like 2006 could only be used with the "any" partial option, and to get country-years for states that were independent on the first day of a year one had to use `state_panel("YYYY-01-01", partial = "exact", ...)`. This can now instead be done with `state_panel(2006, partial = "first", ...)`. 

## New functions

- Added `country_names()` to translate country codes to country names and `prettyc()` to shorten some of the longer country names, like "Macedonia, the former Yugoslav Republic of".
- Updated vignette on G&W and COW differences to take into account when trying to translate between codes.
- Added `compare()` helper to compare two statelist data frames prior to merging. 
- Added `parse_date()` to handle more flexible "start" and "end" date input (#12). 

## Bug fixes

- fixed a misspelled country name, "Rumania" to "Romania"

# states 0.2.2

- Added option to use simpler input when generating a yearly panel, i.e. `state_panel(2001, 2005)` instead of `state_panel("2001-01-01", "2005-01-01", by = "year", partial = "any")`. 
- Changed sfind() so that it ignores capitalization and treats character numbers as numbers. These pairs of queries now produce the same results, unlike before:
  - "Gabon" and "gabon",
  - 260 and "260"
- Changes in plot_missing() and missing_info(): 
  - make "data" the first argument and "x" the second argument so that it works nicer in pipes. 
  - add more intelligent defaults so that not all arguments have to be explicitly specified.
  - rename the "time_unit" argument to "period".
  - added "partial" argument, it works the same as in `state_panel()`. 
- Fixed plot_missing() and missing_info() error when "data" is a tibble ("tbl_df"). 


# states 0.2.1

- `plot_missing` improvements: examples with Polity data, added a `skip_labels` option that will plot every n-th label for countries instead of all labels to avoid overplotting on the y-axis. The latter is inspired by https://github.com/xuyiqing/panelView.
- Added Polity combined score as example data set.
- Fixed encoding issue for `gwstates$country_names` like Cote d'Ivoire and Wüttemberg.

# states 0.2.0

- Initial version on CRAN.
- Refactor `state_panel` and add a partial option to allow including partial state-periods (as opposed to the default which is based on the exact start date, for all period resolutions in "by"). 
- Rework `plot_missing`: fix a bug that would leave out independent states with no cases in the input data; add `missing_info` function that generates the data underlying the plots.
- Add `pkgdown` website for `states` package documentation.

# states 0.1.0

- Initial version on Github. 
- Added a `NEWS.md` file to track changes to the package.



