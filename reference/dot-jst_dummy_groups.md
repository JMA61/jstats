# Internal helper: the categories of each dummy-coded predictor, for plots

The map [`jplot()`](https://jma61.github.io/jstats/reference/jplot.md)
needs to draw a dummy-coded variable as ONE variable (Session 360; the
S359 item): each variable's categories in the order of their codes, the
label each carries in the coefficient table, and the dummy column that
marks it (`NA` for the reference). Built from the same registrations and
the same label lookup the table uses
([`.jst_reg_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_reg_value_labels.md),
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md)),
so the plot and the table cannot label a category two ways, and after
[`.jst_prune_absent_categories()`](https://jma61.github.io/jstats/reference/dot-jst_prune_absent_categories.md),
so a category with no case in the analysis sample is not drawn. Unlike
[`.jst_collect_multicat_regs()`](https://jma61.github.io/jstats/reference/dot-jst_collect_multicat_regs.md)
it keeps a two-category variable (one dummy column): a plot of it has
two categories along the axis.

## Usage

``` r
.jst_dummy_groups(
  dummy_regs,
  auto_cat_regs,
  dummy_coef_names,
  lab_src,
  value_mode
)
```

## Arguments

- dummy_regs:

  List of jdummy registrations, or NULL.

- auto_cat_regs:

  Named list of in-flight registrations, keyed by variable name.

- dummy_coef_names:

  Character vector of dummy column names in the fitted model.

- lab_src:

  Pre-conversion data frame used as the label source.

- value_mode:

  Resolved value.id mode for the labels, as the coefficient table uses
  it.

## Value

A named list, one element per dummy-coded variable in the model, each a
list of `labels` (character) and `dummy` (character, `NA` for the
reference), in code order. Empty when the model has no dummy-coded
predictor.
