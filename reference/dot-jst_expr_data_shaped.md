# Internal helper: is an expression shaped as data?

For the data-first resolver (Session 392): an expression in the data's
place that stopped is read as data – a data frame's name typed wrong in
it said,
[`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md)
– only when it has the shape of one: the object of `[`, `[[`, `$` or
`@`, or a call of a function that takes a data frame and gives one back
([`subset()`](https://rdrr.io/r/base/subset.html),
[`head()`](https://rdrr.io/r/utils/head.html),
[`na.omit()`](https://rdrr.io/r/stats/na.fail.html),
[`merge()`](https://rdrr.io/r/base/merge.html) and kin), parentheses
read through. A condition or a computed vector – `Agee > 40`,
`log(Income)` – is not, and keeps the resolver's stops, which name the
default frame where one is set.

## Usage

``` r
.jst_expr_data_shaped(e)
```

## Arguments

- e:

  The expression.

## Value

TRUE or FALSE.
