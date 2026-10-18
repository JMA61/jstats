# Internal helper: what a rebuilt call still lacks

Ruling R23 (Session 371, the remedy-line audit; Jeff: "All yours
including the ruling"): a stop that rebuilds the user's call – naming
its data frame (the resolver's not-found routes, the no-data-frame
routes), taking a data frame's name out of quotes, leaving out a value
given as the data – checks the call it would offer for the inputs the
function cannot run without. One that would stop again for want of one
gets ruling R22's form instead
([`.jst_gap_stop()`](https://jma61.github.io/jstats/reference/dot-jst_gap_stop.md)):
what is missing, and the function's own example on community.
jrecode(Age) with g6 holding Age had been offered jrecode(g6, Age),
which stopped for its map. The inputs: jrecode()'s map; jrelabel()'s
labels or variable label; jdeclare_missing()'s codes (or range, or
labels) and, with no convention set or named, a convention for a
variable with no declaration of its own; jconvert()'s target with no
convention set; a second variable for jcorr(), jalpha(), jsum() and
javg(); a variable for jdesc(), jfreq() and jplot() (a formula is a
variable list). Only a function with an example has a gap.

## Usage

``` r
.jst_call_gap(fn, cl, envir = parent.frame())
```

## Arguments

- fn:

  Character. The function's name.

- cl:

  The call as it would be offered.

- envir:

  Where the call's data frame is looked for.

## Value

NULL, or a list: what (the input missing, for the lead), verb ("was" or
"were", after a head of the stop's own) and tail (the second line after
"Name a data frame").
