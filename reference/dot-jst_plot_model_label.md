# Internal helper: a model's variable, as its plots title an axis

The variable's label, the name where it has none (the S412 audit's F4,
ruled Session 413), read from the result, which keeps the labels the
analysis ran with: the outcome's from the coefficients' "outcome", a
dummy-coded variable's from its group, any other predictor's from the
coefficients' labels, keyed by term. A result stores a variable's name
where it had no label.

## Usage

``` r
.jst_plot_model_label(x, var, wrap = TRUE)
```

## Arguments

- x:

  A `jst_lm` or `jst_logistic` result.

- var:

  Character(1), the variable's name.

- wrap:

  Logical(1): put a long label on two lines, for an axis.

## Value

Character(1).
