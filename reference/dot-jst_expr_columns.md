# Internal helper: the variables an expression reads from one name

What `dd[dd$Age > 40, ]` or `subset(dd, Age > 40)` reads from `dd`: a
component after `$` or `@`, a literal `[[ ]]` name, and any other name
the expression reads that is no object – a variable read by
[`subset()`](https://rdrr.io/r/base/subset.html)'s condition. For ruling
R36's match inside an expression.

## Usage

``` r
.jst_expr_columns(e, nm, envir)
```

## Arguments

- e:

  The expression.

- nm:

  Character(1). The name.

- envir:

  The caller's environment.

## Value

Character, possibly empty.
