# Internal: a model's sample checked and its absent categories pruned

A predictor dummy-coded in the call with one category stops (S347); the
categories the analysis sample lacks are pruned from the model frame,
the formula and the registrations (.jst_prune_absent_categories()); a
predictor constant in the sample stops; no more cases than coefficients
stops (S347). jlm() and jlogistic() each held this block (Session 386,
the twin build), differing only in the noun.

## Usage

``` r
.jst_model_prefit(
  mf,
  data,
  formula,
  dummy_regs,
  expanded_originals,
  auto_cat_regs,
  dummy_coef_names,
  ref_cats,
  auto_ref_cats,
  value_mode_coef,
  sample_info,
  .jst_data_name,
  pipeline_data,
  one_cat_in_call,
  noun
)
```

## Arguments

- mf, data, formula:

  The model frame, the data and the formula.

- dummy_regs, expanded_originals, auto_cat_regs, dummy_coef_names,
  ref_cats, auto_ref_cats:

  The registrations and their columns.

- value_mode_coef:

  The value-label mode of the coefficient rows.

- sample_info, .jst_data_name:

  The Case Processing counts and the data frame's name.

- pipeline_data:

  The pipeline's data, for the constant-predictor stop.

- one_cat_in_call:

  A one-category predictor set aside, or NULL.

- noun:

  Character(1): "A regression" or "A logistic regression".

## Value

list(formula, mf, dummy_regs, auto_cat_regs, dummy_coef_names, ref_cats,
auto_ref_cats, all_ref_cats).
