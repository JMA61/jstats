# Internal helper: get registered dummy variables for a named data frame

Looks up the
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
registrations stored under the `.jst_dummy` option for a specific data
frame name. Returns `NULL` if no dummies are registered for that data
frame.

## Usage

``` r
.jst_get_dummy(data_name)
```

## Arguments

- data_name:

  Character string giving the data frame name to look up.

## Value

The stored dummy-registration settings list, or `NULL` if none.
