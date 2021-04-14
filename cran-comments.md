## Test environments

- local R installation (macOS), R 4.0.5
- win-builder (release)
- win-builder (devel)

On GitHub Actions:

- macOS R-release 
- Windows R-release
- Ubuntu R-release, R-devel

On R-Hub:

- windows-x86_64-devel (r-devel)
- ubuntu-gcc-release (r-release)
- fedora-clang-devel (r-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

**********

Various minor updates.

There are 3 WARNINGS right now in the CRAN checks, related to building one of the package Rmarkdown vignettes that depends on the DT package:

`there is no package called 'webshot'`

I'm not getting them anywhere else. Not sure what to do about this. 
