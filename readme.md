# states

Create country-year data templates. This is all in a very bare-bones state currently.

What the package does:

1. It contains the Gleditsch and Ward (G&W) as well as the Correlates of War (COW) state system membership lists. 
    ```r
    data(gwstates)
    data(cowstates)
    ```
2. You can use it to build a country-year template that matches either the COW or G&W state lists. 
    ```r
    foo <- state_panel(as.Date("1991-01-01"), as.Date("2010-01-01"), by = "year")
    ```
3. For manual coding, search the state lists with `sfind()`:
    ```r
    sfind("Myanmar")
    sfind("Myanmar", "G&W")
    sfind("Myanmar", "COW")
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

- change state_panel to recognize date resolutions, e.g. "2017-05" implies monthly data
  - use broad matching, i.e. for "2017" match any state that existed at any point
    in 2017, more specific matching can in most cases be done by specifying more predise dates, e.g. "2017-12-31" to match at end of year
  - year: first, last are unambiguous, no issues
  - day: no ambiguity
  - month: first and middle are clear, last day of month is not
  - other formats? week, quarter?

state_panel(2011, 2013) shoud make annual data, include South Sudan
state_panel("2011-07", "2012-07") should make monthly data, include SS
state_panel("2011-07", "2012-07", last_day = TRUE) monthly data, no SS
state_panel("2011", "2012", last_day = TRUE) monthly data 2011-01:2012-12
state_panel("2011-07", "2012-07", last_day = TRUE) monthly data 2011-07:2012-07
state_panel("2011-07-01", "2012-07-01", last_day = TRUE) monthly data, 2011-07:2012-07, no SS

- add something that gives overview of G&W/COW differences for when coding between by hand

Later:

- spatial lagging
- dyadic data

### Spatial lag links

https://aledemogr.wordpress.com/2015/10/09/creating-neighborhood-matrices-for-spatial-polygons/

http://www.people.fas.harvard.edu/~zhukov/Spatial3.pdf


