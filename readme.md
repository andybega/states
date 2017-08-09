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

## Citations

For the [Gleditsch and Ward (G&W) state data](http://privatewww.essex.ac.uk/~ksg/statelist.html):

Gleditsch, Kristian S. & Michael D. Ward. 1999. "Interstate System Membership: A Revised List of the Independent States since 1816." International Interactions 25: 393-413.

For the [Correlates of War (COW) state data](http://www.correlatesofwar.org/data-sets/state-system-membership):

Correlates of War Project. 2017. "State System Membership List, v2016." Online, http://correlatesofwar.org


## Notes

### TODO

- plot_missing to visualize missing data

Later:

- spatial lagging
- dyadic data

### Spatial lag links

https://aledemogr.wordpress.com/2015/10/09/creating-neighborhood-matrices-for-spatial-polygons/

http://www.people.fas.harvard.edu/~zhukov/Spatial3.pdf


