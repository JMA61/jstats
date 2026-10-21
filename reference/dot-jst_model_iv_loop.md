# Internal: a model's predictors, checked and made ready to fit

The name arguments checked against the predictors (the outcome left out
of numeric = and count =, and a note when categorical = names it; a name
that is not a predictor stops; a variable in two of them stops), then
each predictor: a per-call override (numeric =, count =, categorical =),
a computed term left as it is, else the classifier – categorical by
intent gets an in-flight dummy registration, otherwise it enters as
numbers, with the dichotomy note or one seems-categorical warning for
all – and the in-flight registrations expanded into dummy columns. jlm()
and jlogistic() each held the loop and the expansion (Session 386, the
twin build); the checks were jlm()'s alone, and jlogistic() gains them
(D2, the S385 drift finding).

## Usage

``` r
.jst_model_iv_loop(
  data,
  formula,
  model_vars,
  dv_name,
  iv_names,
  numeric,
  categorical,
  count,
  dummy_coef_names,
  expanded_originals,
  resolved,
  pipeline,
  data_in,
  .jst_data_name,
  .jst_data_kind,
  .jst_default_used,
  formula_typed,
  auto_ref_cats,
  auto_cat_regs,
  one_cat_in_call,
  seems_cat,
  fn,
  skip_absent
)
```

## Arguments

- data, formula, model_vars:

  The data, formula and its variables.

- dv_name:

  Character(1): the outcome.

- iv_names:

  Character: the predictors.

- numeric, categorical, count:

  The name arguments, read.

- dummy_coef_names, expanded_originals:

  jdummy()'s columns and the variables they replaced.

- resolved:

  The transforms' resolution (its computed columns).

- pipeline, data_in:

  The pipeline's result and the data before it.

- .jst_data_name, .jst_data_kind, .jst_default_used, formula_typed:

  The data's name and kind, the default flag and the formula as typed.

- auto_ref_cats, auto_cat_regs, one_cat_in_call, seems_cat:

  Their values so far.

- fn:

  Character(1): the calling function.

- skip_absent:

  Logical(1): pass over a predictor not in the data (jlogistic()'s
  guard).

## Value

list(data, formula, model_vars, dummy_coef_names, auto_cat_regs,
auto_ref_cats, one_cat_in_call, numeric, categorical, count).
