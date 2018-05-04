# states 0.2.1

* `plot_missing` improvements: examples with Polity data, added a `skip_labels` option that will plot every n-th label for countries instead of all labels to avoid overplotting on the y-axis. The latter is inspired by https://github.com/xuyiqing/panelView.
* Added Polity combined score as example data set.
* Fixed encoding issue for `gwstates$country_names` like Cote d'Ivoire and Wüttemberg.

# states 0.2.0

* Initial version on CRAN.
* Refactor `state_panel` and add a partial option to allow including partial state-periods (as opposed to the default which is based on the exact start date, for all period resolutions in "by"). 
* Rework `plot_missing`: fix a bug that would leave out independent states with no cases in the input data; add `missing_info` function that generates the data underlying the plots.
* Add `pkgdown` website for `states` package documentation.

# states 0.1.0

* Initial version on Github. 
* Added a `NEWS.md` file to track changes to the package.



