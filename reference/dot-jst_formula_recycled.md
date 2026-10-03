# Internal helper: find a workspace vector that a computed term recycles

A name inside a computed term that is not a variable resolves in the
formula's environment (the S322 constant rule), and nothing checked its
length: with `v <- c(1, 2, 3)`, `I(Stress * v)` fitted on R's recycled
`1, 2, 3, 1, 2, 3, ...` behind its "longer object length" warning – with
no warning at all when the row count divides by the length – and
[`lm()`](https://rdrr.io/r/stats/lm.html) does the same (Session 324,
the S323 item). This hands each computed term of the formula, both
sides, to
[`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md),
which says what counts as recycled.

## Usage

``` r
.jst_formula_recycled(formula, data, enclos)
```

## Arguments

- formula:

  The analysis formula as typed.

- data:

  The analysis data frame, after the pipeline's filters.

- enclos:

  The environment the formula's other names resolve in.

## Value

NULL when there is none; otherwise the
[`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)
result.
