# states 0.2.2.9000


- plot_missing()'s "space" argument has been renamed "ccode". 

## Improved support for state_panel shortcuts

`state_panel()` has further improved support for input shortcuts (#3):

- Accepted formats for the "start" and "end" arguments now incluce 2006, "2006", "2000-06", and "2006-06-01". See `parse_date()` for details. 
- The implied time period is now also inferred from shortcut input when "by" is left at the new default of NULL. 
- The "partial" option has gained new "first" and "last" values that also support shortcut input. Previously a shortcut input like 2006 could only be used with the "any" partial option, and to get country-years for states that were independent on the first day of a year one had to use `state_panel("YYYY-01-01", partial = "exact", ...)`. This can now instead be done with `state_panel(2006, partial = "first", ...)`. 

## New functions

- Added `country_names()` to translate country codes to country names and `prettyc()` to shorten some of the longer country names, like "Macedonia, the former Yugoslav Republic of".
- Updated vignette on G&W and COW differences to take into account when trying to translate between codes.
- Added `compare()` helper to compare two statelist data frames prior to merging. 
- Added `parse_date()` to handle more flexible "start" and "end" date input (#12). 

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



