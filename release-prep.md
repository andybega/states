Notes to prep for release
=========================

```r
urlchecker::url_check()
devtools::build_readme()

devtools::check(remote = TRUE, manual = TRUE)
devtools::check_win_devel()
devtools::check_win_release()
ch <- rhub::check_for_cran()

# monitor progress
list_package_checks()

# eventually:
ch$cran_summary()

# finally:
devtools::release()

# once accepted, 
# 1. tag the release commit on GH
# 2. Attach to that a tarball built with devtools::build()
```
