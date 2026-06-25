# Internal helper: set complete-case settings for a named data frame

Stores complete-case settings under the `.jst_complete` option, keyed by
data frame name. Used internally by
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md).

## Usage

``` r
.jst_set_complete(data_name, settings)
```

## Arguments

- data_name:

  Character string giving the data frame name. If `NULL`, the call is a
  silent no-op.

- settings:

  A list of complete-case settings to store.

## Value

`invisible(NULL)`. Called for its side effect on the `.jst_complete`
option.
