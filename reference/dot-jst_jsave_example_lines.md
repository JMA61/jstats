# Internal helper: the example line under jsave()'s front-door stops

The stops for a data argument that is not found, cannot be evaluated, is
NULL or is not a data frame each gave "Provide a data frame, e.g.
jsave(MyData, "mydata.sav")" on the line of the sentence before it.
Since Session 368 (Fix Slate 15) each gives "Provide a data frame, for
example:" and the call on a line of its own (Rules E and L), the call
naming the one data frame in the workspace, as the no-default stop has
since Session 367 (MyData when there is none or there are several). The
file is "mydata.sav", except under the stop for a name not found – most
often a misspelled data frame – where the file the call gave is kept
when it is a quoted name: `jsave(communty, "community.sav")` is offered
`jsave(community, "community.sav")`. An object that exists but is not a
data frame keeps the example file, since the file the call named was
meant for that object.

## Usage

``` r
.jst_jsave_example_lines(mc, envir, keep_file = FALSE)
```

## Arguments

- mc:

  The call, matched
  ([`match.call()`](https://rdrr.io/r/base/match.call.html) in jsave()).

- envir:

  The caller's environment, where the data frames are looked for.

- keep_file:

  Logical; keep the call's file name in the example.

## Value

Character(1); the "Provide a data frame, for example:" heading and the
call, two lines.
