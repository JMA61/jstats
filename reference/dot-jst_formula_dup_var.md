# Internal: detect a variable appearing on both sides of an analysis formula

Checks a two-sided analysis formula for a variable named on both the
left- and right-hand sides (e.g. `MathScore ~ MathScore` or
`MathScore ~ MathScore + Age`). Such formulas cannot be caught
downstream via `all.vars(formula)`, which deduplicates names: the
formula functions then either index a second variable that is not there
(jt / jaov / jcrosstab fall through to raw base R errors) or hand the
formula to [`lm()`](https://rdrr.io/r/stats/lm.html) /
[`glm()`](https://rdrr.io/r/stats/glm.html), which silently drops the
response from the right-hand side and fits a different model than the
user wrote (jlm / jlogistic). Callers stop with a clear, named message
when this helper returns a name.

## Usage

``` r
.jst_formula_dup_var(formula)
```

## Arguments

- formula:

  The user's analysis formula.

## Value

The first duplicated variable name (character scalar), or `NULL` when
the formula is one-sided, not a formula, or has no variable in both
roles.
