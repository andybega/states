# Unreleased

- Added option to use simpler input when generating a yearly panel, i.e. `state_panel(2001, 2005)` instead of `state_panel("2001-01-01", "2005-01-01", by = "year", partial = "any")`. 
- Changed sfind() so that it ignores capitalization and treats character numbers as numbers. These pairs of queries now produce the same results, unlike before:
  - "Gabon" and "gabon",
  - 260 and "260"
- Changed plot_missing() and missing_info() to work nicer with pipes by making "data" the first argument and "x" the second argument. 
- Added "partial" argument for `plot_missing()`, it works the same as in `state_panel()`. 
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



