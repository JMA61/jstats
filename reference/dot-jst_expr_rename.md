# Internal helper: a name put in another's place in an expression

Every place `from` is read as a value – the places
[`.jst_expr_symbols()`](https://jma61.github.io/jstats/reference/dot-jst_expr_symbols.md)
collects: not a call's function, not the component after `$` or `@`, not
inside `::` or an inline function – becomes `to`: `dd[dd$Age > 40, ]`
becomes `d[d$Age > 40, ]`.

## Usage

``` r
.jst_expr_rename(e, from, to)
```

## Arguments

- e:

  The expression.

- from, to:

  Character(1). The names.

## Value

The expression.
