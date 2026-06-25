# Internal helper: resolve the `at` argument for regression-line plots

Computes the values at which non-focal predictors should be held when
producing a fitted-line plot for a multiple-predictor regression. The
`at` argument accepts `zero`, `mean`, `mixed` (zero for dummies, mean
for numeric), or a named list giving an explicit value per non-focal
predictor.

## Usage

``` r
.jst_resolve_at(at, model_frame, dv_name, focal_name, dummy_coef_names)
```

## Arguments

- at:

  User-supplied value: `zero`, `mean`, `mixed`, or a named list of
  explicit hold values.

- model_frame:

  Data frame used to fit the model (post-conversion).

- dv_name:

  Character. The dependent variable name.

- focal_name:

  Character. The focal predictor name (the one that varies along the
  x-axis).

- dummy_coef_names:

  Character vector of registered dummy-coefficient names, used to
  identify which non-focal predictors are dummies.

## Value

A named list of hold values, one per non-focal predictor. Empty list if
there are no non-focal predictors.
