# Internal helper: warn that the fit dropped a term, naming it

A predictor that is an exact linear combination of the others gets an NA
coefficient from [`lm()`](https://rdrr.io/r/stats/lm.html) and
[`glm()`](https://rdrr.io/r/stats/glm.html), and the coefficient table
has no row for it. Until Session 359 jlm() and jlogistic() said only
"One or more variables have been removed from the model due to
collinearity.", and the reader had to find the missing row (the S347
item; voice Rule AI: a cause the package knows is stated). The warning
now names each dropped term as the table would have named it – a factor
level and a numeric dichotomy cleaned by
[`.jst_clean_coef_names()`](https://jma61.github.io/jstats/reference/dot-jst_clean_coef_names.md),
an interaction with `" * "` – and says why it was dropped.

## Usage

``` r
.jst_warn_aliased(model, data, formula, dummy_coef_names = character(0))
```

## Arguments

- model:

  The fitted `lm` or `glm` object.

- data:

  The data frame the model was fitted on.

- formula:

  The formula as fitted.

- dummy_coef_names:

  Character; the generated dummy columns, left unchanged by the
  cleaning, as at the table.

## Value

Invisible NULL; warns when a coefficient is NA.
