# Internal helper: jsave()'s stop for a file with no data frame to save

`jsave("t13.rds")` with no
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
names the file and writes nothing (Session 351);
`jsave(file = "t13.rds")` joins it (Session 367). Since Session 367 (Fix
Slate 14) the stop offers both routes, as the analysis functions' stop
for the same condition does: the call with a data frame named first, or
a default set and the call run again. The data frame named is the one
data frame in the workspace
([`.jst_frame_holding()`](https://jma61.github.io/jstats/reference/dot-jst_frames_holding.md)
with no variables to match: jsave() has no variable to look for, so any
data frame counts), or MyData when there is none or there are several.
Both lines keep the call's other arguments, and file = when the call
named the file with it.

## Usage

``` r
.jst_jsave_no_frame_stop(lead, file_val, mc, envir)
```

## Arguments

- lead:

  Character(1); the stop's first sentence, ending in a newline.

- file_val:

  Character(1); the file name the call gave.

- mc:

  The call, matched
  ([`match.call()`](https://rdrr.io/r/base/match.call.html) in jsave()).

- envir:

  The caller's environment, where the data frames are looked for.

## Value

Does not return; stops.
