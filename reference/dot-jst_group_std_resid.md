# Internal helper: standardized residuals of a comparison of groups

Each case's distance from its group's mean, divided by its standard
error: `e / (s * sqrt(1 - 1/n))`, with `n` the group's size and `s` the
pooled standard deviation (`pooled = TRUE`, Student's t-test and the
traditional ANOVA, where this is
[`rstandard()`](https://rdrr.io/r/stats/influence.measures.html) of the
one-way model) or the group's own (`pooled = FALSE`, Welch's tests,
whose groups need not share a variance). A paired test passes the
differences as one group. A case of a one-case group, or of a group with
no spread, gets `NA`. What
[`jt()`](https://jma61.github.io/jstats/reference/jt.md) and
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) return as
`residuals` and the normal Q-Q plot draws (Session 375; ruling R14, part
2).

## Usage

``` r
.jst_group_std_resid(y, g, pooled = TRUE)
```

## Arguments

- y:

  Numeric vector; the outcome (or the paired differences).

- g:

  The groups, any type; a case missing on either is left out.

- pooled:

  Logical; pool the standard deviation across the groups.

## Value

Numeric vector, the cases complete on both, names kept.
