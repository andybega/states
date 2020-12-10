## Test environments

- local R installation (macOS), R 4.0.3
- win-builder (release)
- win-builder (devel)

On GitHub Actions:

- macOS R-release 
- Windows R-release
- Ubuntu R-release, R-devel

On R-Hub:

- Ubuntu, R-release
- Fedora, R-devel

## R CMD check results

0 errors | 0 warnings | 0 notes

**********

This fixes the current ERRORs on the CRAN Package Checks with R-devel due to the change in `all.equal()` (which in R-devel compares environments now). 
