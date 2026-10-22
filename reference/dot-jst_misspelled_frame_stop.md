# Internal helper: the stop for a data frame's name typed wrong (ruling R36)

"'dd' not found." / "If you meant the data frame d:" and the call as
typed with the data frame in place of the name. When that call would
still stop for want of an input – jrecode(dd, Age) with no map – ruling
R23's stop is given instead, its lead "'dd' not found, and no map was
named." (.jst_gap_stop()), so no line offered stops again.

## Usage

``` r
.jst_misspelled_frame_stop(fn, typed_name, fr, offered, envir, cl = NULL)
```

## Arguments

- fn:

  Character(1). The user-facing function's name.

- typed_name:

  Character(1). The name typed.

- fr:

  Character(1). The data frame meant
  ([`.jst_misspelled_frame()`](https://jma61.github.io/jstats/reference/dot-jst_misspelled_frame.md)).

- offered:

  The call to offer.

- envir:

  The caller's environment.

- cl:

  The call as typed, for ruling R23's example; NULL for none.

## Value

Does not return; stops.
