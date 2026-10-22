# Internal helper: a column an expression reads that its data frame lacks

For
[`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md).
Walks the expression for a data frame of the caller's – a name holding
one – read with `$` or a literal `[[ ]]`, or given to
[`subset()`](https://rdrr.io/r/base/subset.html), and collects the
columns it reads that the frame does not have: `d$Agee`, `d[["Agee"]]`,
or a name in `subset(d, Agee > 40)`'s condition or `select` that is
neither a variable of `d` nor an object. The first frame with such a
column is the one reported, every column it lacks named.

## Usage

``` r
.jst_expr_missing_columns(e, envir)
```

## Arguments

- e:

  The expression.

- envir:

  The caller's environment.

## Value

NULL, or a list of `frame` (its name), `value` (the data frame) and
`cols` (the columns it lacks).
