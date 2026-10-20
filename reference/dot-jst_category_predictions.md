# Internal helper: the prediction at each category of a dummy-coded variable

One row per category (Session 360): its dummy columns set as the
category's cases have them, every other predictor held where `at_vals`
puts it, and the prediction with its 95% interval – the confidence
interval of the mean for a linear model, the interval on the logit scale
carried to the probability scale for a logistic one, as the fitted line
and the S-curve compute theirs.

## Usage

``` r
.jst_category_predictions(
  model,
  group,
  at_vals,
  logistic = FALSE,
  link = FALSE
)
```

## Arguments

- model:

  The fitted `lm` or `glm`.

- group:

  One element of `.jst_plot_variables()$groups`.

- at_vals:

  The held values, by model column.

- logistic:

  Logical; TRUE for a `glm` on the logit link.

- link:

  Logical; with `logistic`, TRUE keeps the prediction and its interval
  on the logit scale (the logit plot, Session 378).

## Value

A data frame: `x` (a factor of the categories), `fit`, `lwr`, `upr`.
