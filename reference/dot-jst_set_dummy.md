# Internal helper: set registered dummy variables for a named data frame

Stores dummy registrations under the `.jst_dummy` option, keyed by data
frame name. Used internally by
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md).

## Usage

``` r
.jst_set_dummy(data_name, settings)
```

## Arguments

- data_name:

  Character string giving the data frame name.

- settings:

  A list of dummy registrations to store.

## Value

`invisible(NULL)`. Called for its side effect on the `.jst_dummy`
option.
