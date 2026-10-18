# Internal helper: the example ruling R22's stop gives, per function

One line per function on community, the same line the function's own
no-variable stop gives where it has one
([`.jst_no_var_example()`](https://jma61.github.io/jstats/reference/dot-jst_no_var_example.md)).
Moved out of
[`.jst_no_frame_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_frame_stop.md)
at Session 371 so ruling R23's stop
([`.jst_gap_stop()`](https://jma61.github.io/jstats/reference/dot-jst_gap_stop.md))
gives the same line.

## Usage

``` r
.jst_r22_example(fn)
```

## Arguments

- fn:

  Character. The function's name.

## Value

NULL for a function with no entry, else a list: call, n, and optionally
lhs, what, line2, noun, named, keep, provide (see
[`.jst_no_var_example()`](https://jma61.github.io/jstats/reference/dot-jst_no_var_example.md)).
