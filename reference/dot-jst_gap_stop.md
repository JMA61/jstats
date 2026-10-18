# Internal helper: ruling R23's stop

What the rebuilt call lacks, then ruling R22's line: "no data frame and
no map were named." / "Name a data frame, one of its variables and a
map, for example:" and the function's example on community. A stop with
a first sentence of its own passes it as `head` ("\\g6\\ is in quotes",
"1:3 is not a data frame"), and the lead becomes "

, and no variables were named.". Session 371.

## Usage

``` r
.jst_gap_stop(fn, gap, cl = NULL, head = NULL, qual = "")
```

## Arguments

- fn:

  Character. The function's name.

- gap:

  The
  [`.jst_call_gap()`](https://jma61.github.io/jstats/reference/dot-jst_call_gap.md)
  result.

- cl:

  The call, for its display options; NULL for none.

- head:

  Optional first clause, in place of "no data frame".

- qual:

  Words after "Name a data frame" (" without quotes").

## Value

Does not return; stops.
