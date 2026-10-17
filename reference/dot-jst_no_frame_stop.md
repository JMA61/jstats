# Internal helper: the stop for a call with no data frame and no default

`jt(Score ~ Gender)`,
[`jscreen()`](https://jma61.github.io/jstats/reference/jscreen.md) or
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) with no
data frame named and no
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.
Until Session 368 (Fix Slate 15) every function reaching
[`.jst_resolve_data()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_data.md)
this way stopped with "No data frame specified and no default set. Use
juse() to set a default.": one route, two sentences on one line. It now
offers both routes, as the resolver's stop for a name not found and
jsave()'s since Session 367 do
([`.jst_jsave_no_frame_stop()`](https://jma61.github.io/jstats/reference/dot-jst_jsave_no_frame_stop.md)):
the call with the data frame named, or a default set and the call run
again.

## Usage

``` r
.jst_no_frame_stop(envir)
```

## Arguments

- envir:

  The caller's environment, where the data frames are looked for.

## Value

Does not return; stops.

## Details

The call is the user's
([`.jst_caller_call()`](https://jma61.github.io/jstats/reference/dot-jst_caller_call.md)).
In a formula call the data frame goes after the formula –
`jt(Score ~ Gender, d)`, or `data = d` after a formula given as
`formula =` – and the data frame named is the one data frame in the
workspace that holds every variable the formula names. In any other call
it goes first, in place of an empty first argument (`jdesc(, Age)`) when
there is one, and the variables to match are those of the call's unnamed
arguments; a call with none, such as
[`jscreen()`](https://jma61.github.io/jstats/reference/jscreen.md), has
no variable to match, so any one data frame counts, as in jsave(). With
none or several, MyData. The rest of the call is kept as typed; the
second route runs the call as typed.
