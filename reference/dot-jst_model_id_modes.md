# Internal: a model's value.id and variable.id, checked and resolved

value.id's legend modes are refused (the coefficient table has no legend
for values); value_mode_coef folds a global legend setting into "both".
variable.id governs the coefficient rows and the variable-label legend.
jlm() and jlogistic() each held this block (Session 386, the twin
build), before any output.

## Usage

``` r
.jst_model_id_modes(value.id, variable.id)
```

## Arguments

- value.id, variable.id:

  The call's arguments.

## Value

list(value_mode, value_mode_coef, vlmode).
