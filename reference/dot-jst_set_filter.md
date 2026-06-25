# Internal helper: set filter settings for a named data frame

Stores filter settings under the `.jst_filter` option, keyed by data
frame name. Used internally by
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md).

## Usage

``` r
.jst_set_filter(data_name, settings)
```

## Arguments

- data_name:

  Character string giving the data frame name. If `NULL`, the call is a
  silent no-op.

- settings:

  A list of filter settings to store.

## Value

`invisible(NULL)`. Called for its side effect on the `.jst_filter`
option.
