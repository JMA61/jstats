# Internal helper: a model's variables as its plots name them

A dummy-coded predictor is fit as one column per category but is ONE
variable (Session 360; the S359 item). The model frame of `y ~ x + g`, g
with four categories, has the columns `x`, `g_b`, `g_c` and `g_d`; until
v0.9.232 [`jplot()`](https://jma61.github.io/jstats/reference/jplot.md)
drew an effect plot for each column, took `g_b` as the fit plot's
default focal variable when g came first, and refused `focal = g` with
the four columns listed. Here each group of dummy columns is replaced by
its variable, at the place of its first column.

## Usage

``` r
.jst_plot_variables(x, iv_names)
```

## Arguments

- x:

  A `jst_lm` or `jst_logistic` result.

- iv_names:

  Character; the model frame's predictor columns.

## Value

A list: `vars`, the variables in model order; `groups`, the result's
`dummy_groups` whose dummy columns are all in the model frame (a result
made before Session 360 has none, and its columns are drawn as before);
and `owner`, the variable of each dummy column, named by column.
