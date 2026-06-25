# Internal helper: print a role-grouped model variable-label legend

The regression layout's replacement for the flat `.print_var_labels`
list: lists a model's variables grouped by role – the outcome first,
then the predictors. A variable with a label that differs from its name
shows as "name = label"; a variable with no label (or a label equal to
its name) shows as the bare "name" (absence of a meaningful label is
conveyed by its absence, not by a "None" marker). Used by jlm and
jlogistic in the "legend" and "legend.bottom" variable.id modes.
Predictors are listed by their original formula names (e.g. "Program"),
not expanded dummy columns; per-dummy-level value labelling is handled
separately by the value.id coefficient work. Matches the flat legend's
indented-lines + trailing-blank structure so co-located blocks space the
same way.

## Usage

``` r
.print_model_var_labels(data, dv_name, iv_names)
```

## Arguments

- data:

  A data frame (or pre-conversion label source) whose columns may carry
  variable labels.

- dv_name:

  Character. The outcome (response) variable name.

- iv_names:

  Character vector. The predictor variable names, in order.
