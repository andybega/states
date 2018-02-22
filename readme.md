# states

[![CRAN versions](http://www.r-pkg.org/badges/version/states)](http://www.r-pkg.org/badges/version/states)
[![Travis-CI Build Status](https://travis-ci.org/andybega/states.svg?branch=master)](https://travis-ci.org/andybega/states)

Create country-year/month/day panels consistent with the COW or Gleditsch & Ward lists of independent states. I mainly use this for merging different data sources: 

1. Create a master template that reflects one of the independent states lists. 
2. For each data source, normalize to a copy of the master template. Doing this by source makes it easier to identify and address issues like missing values or observation for non-independent states. 
3. In the end, merge everything together. Since all the inputs are already normalized to a proper state panel list, there should be no issues.

What the package does:

1. It contains the Gleditsch and Ward (G&W) as well as the Correlates of War (COW) state system membership lists. 
    ```r
    data(gwstates)
    data(cowstates)
    ```
    Search them with `sfind`, this can be helpful for manual coding:
    ```r
    sfind(260)
    sfind("German")
    ```
2. You can use it to build a country-year template that matches either the COW or G&W state lists. 
    ```r
    countries <- state_panel("1991-01-01", "2010-01-01", by = "year")
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

