# Internal helper: the way out of a stop that a filter caused

A `subset =` is removed from the call; a stored filter is set aside with
the line
[`.jst_filter_exits()`](https://jma61.github.io/jstats/reference/dot-jst_filter_exits.md)
gives for it.

## Usage

``` r
.jst_filter_way_out(fn, data_name, purpose)
```

## Arguments

- fn:

  The list
  [`.jst_filters_naming()`](https://jma61.github.io/jstats/reference/dot-jst_filters_naming.md)
  returns.

- data_name:

  Character(1); the data frame's name.

- purpose:

  Character(1); what the way out is for ("To estimate it").

## Value

Character(1), with no closing newline.
