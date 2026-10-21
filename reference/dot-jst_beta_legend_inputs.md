# Internal: the inputs of a model's beta-column legends

The computed terms read as powers or products (.jst_poly_term()), the
highest power, whether the model has an interaction or a power, and the
products computed by hand in the data, those the fit dropped left out
(.jst_hand_products()). jlm() and jlogistic() each held this block
(Session 386, the twin build); each then calls .jst_beta_legends() as
before, jlogistic() appending to what it has (the S383 caution).

## Usage

``` r
.jst_beta_legend_inputs(
  computed,
  mf,
  data,
  enclos,
  term_keys,
  dummy_coef_names,
  model
)
```

## Arguments

- computed:

  Character: the computed terms' columns.

- mf, data:

  The model frame and the data.

- enclos:

  The formula's environment.

- term_keys:

  The design matrix's coefficient names.

- dummy_coef_names:

  jdummy()'s columns.

- model:

  The fitted model.

## Value

list(poly_info, poly_kinds, pow_max, has_int, has_pow, pow_noun, hand,
fit_b, hand_sq).
