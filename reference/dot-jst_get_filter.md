# Internal helper: get filter settings for a named data frame

Looks up the
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
settings stored under the `.jst_filter` option for a specific data frame
name. Returns `NULL` if no filter is set for that data frame.

## Usage

``` r
.jst_get_filter(data_name)
```

## Arguments

- data_name:

  Character string giving the data frame name to look up. If `NULL`,
  returns `NULL`.

## Value

The stored filter settings list, or `NULL` if none.
