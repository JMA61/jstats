# Internal helper: get complete-case settings for a named data frame

Looks up the
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
settings stored under the `.jst_complete` option for a specific data
frame name. Returns `NULL` if no complete-case settings are stored for
that data frame.

## Usage

``` r
.jst_get_complete(data_name)
```

## Arguments

- data_name:

  Character string giving the data frame name to look up. If `NULL`,
  returns `NULL`.

## Value

The stored complete-case settings list, or `NULL` if none.
