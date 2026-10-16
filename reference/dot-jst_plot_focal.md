# Internal helper: the focal variable of a fit or probability plot

`focal` names a VARIABLE of the model (Session 360): a dummy-coded one
by its own name, and a dummy column by the variable it belongs to, so
`focal = g_b`, which the old refusal listed, draws g. With no `focal`,
the first predictor that is not dummy-coded, since a fitted line needs a
numeric axis; a model whose predictors are all dummy-coded takes its
first. A name that is not a variable of the model stops, the model's
variables listed.

## Usage

``` r
.jst_plot_focal(focal_name, pv)
```

## Arguments

- focal_name:

  Character(1) or NULL, as deparsed from the call.

- pv:

  The list
  [`.jst_plot_variables()`](https://jma61.github.io/jstats/reference/dot-jst_plot_variables.md)
  returns.

## Value

Character(1): the focal variable (`NA` for a model with no predictors).
