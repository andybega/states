# states

Create country-year data templates. This is all in a very bare-bones state currently.

This package does two things:

1. It contains the Gleditsch and Ward (G&W) as well as the Correlates of War (COW) state system membership lists. 
    ```r
    data(gwstates)
    data(cowstates)
    ```
2. You can use it to build a country-year template that matches either the COW or G&W state lists. 
    ```r
    foo <- state_panel(as.Date("1991-01-01"), as.Date("2010-01-01"), by = "year")
    ```

## Install

Not on CRAN, so:

```r
library(devtools)
install_github("andybega/states")
```

## Notes

### TODO

- plot_missing to visualize missing data

Later:
- spatial lagging
- dyadic data

### Spatial lag links

https://aledemogr.wordpress.com/2015/10/09/creating-neighborhood-matrices-for-spatial-polygons/

http://www.people.fas.harvard.edu/~zhukov/Spatial3.pdf
