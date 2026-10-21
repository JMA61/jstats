# Internal: a model's coefficient rows made ready to print

Under variable.id = "labels" the rows are relabeled; the categorical
predictors' dummy rows are grouped under their variable
(.jst_collect_multicat_regs(), .jst_group_dummy_coefs()). jlm() and
jlogistic() each held this block (Session 386, the twin build).

## Usage

``` r
.jst_coef_display(
  out_coefs,
  vlmode,
  lab_src,
  formula,
  dummy_regs,
  auto_cat_regs,
  dummy_coef_names,
  value_mode_coef,
  show_ref_categories
)
```

## Arguments

- out_coefs:

  The formatted coefficient table.

- vlmode, lab_src, formula:

  The variable-id mode, the label source and the formula.

- dummy_regs, auto_cat_regs, dummy_coef_names:

  The registrations.

- value_mode_coef, show_ref_categories:

  The display settings.

## Value

list(coef_disp, multi_cat_regs).
