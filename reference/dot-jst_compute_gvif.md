# Internal helper: the generalized VIF of each set of dummy variables

A categorical predictor of three or more categories enters a model as a
set of dummy variables, and the VIF table gave each dummy column its own
VIF, which depends on the reference category; `car::vif()` gives the set
one generalized VIF (Fox and Monette, 1992; the S346 item, built Session
375): `det(R11) * det(R22) / det(R)`, `R` the predictors' correlation
matrix, `R11` the set's block and `R22` the rest's, with
`GVIF^(1/(2*Df))` beside it – on the scale of the square root of a VIF,
so its square compares with the usual VIF guidelines. A set is a
multi-category predictor's dummy columns and, in a model with an
interaction, the interaction columns built on them with the same other
variables (`Age * Region`). Any other column is a set of one, whose GVIF
is its VIF.

## Usage

``` r
.jst_compute_gvif(model, regs)
```

## Arguments

- model:

  A fitted `lm` or `glm`.

- regs:

  The multi-category registrations,
  [`.jst_collect_multicat_regs()`](https://jma61.github.io/jstats/reference/dot-jst_collect_multicat_regs.md).

## Value

`NULL` when no set has two or more columns (the table is then the plain
VIF table), or when the correlation matrix is singular; otherwise a data
frame of `term`, `GVIF`, `Df` and `GVIF_adj` (`GVIF^(1/(2*Df))`), in the
model's column order.

## References

Fox, J., and Monette, G. (1992). Generalized collinearity diagnostics.
*Journal of the American Statistical Association*, 87(417), 178-183.
