# Internal helper: the closing lines of a stored filter's stop

One builder for the way out of every stop a stored
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
filter raises
([`.jst_check_mask_shape()`](https://jma61.github.io/jstats/reference/dot-jst_check_mask_shape.md),
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md)),
so the forms cannot drift. At analysis time (`"stored"`) the filter is
active and re-runs on every analysis of its frame, so both exits are
given, set aside first. When `jsubset(d, on)` refuses to turn a filter
back on (`"reactivate"`, Session 331) the filter is off already: "set it
aside" would name the state it is in, so the message says the filter
stays off and gives the delete exit alone.

## Usage

``` r
.jst_filter_exits(data_name, origin = c("stored", "reactivate"))
```

## Arguments

- data_name:

  Character. The data frame's name.

- origin:

  `"stored"` or `"reactivate"`.

## Value

A character string: the message's closing lines.
