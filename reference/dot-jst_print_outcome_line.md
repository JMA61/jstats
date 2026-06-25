# Internal helper: print the outcome name beneath a regression table

Names the model outcome on its own line directly below the Coefficients
table, for the non-legend variable.id modes. The line follows
variable.id: the bare name under "names", the variable label under
"labels", and "name: label" under "both" – each degrading to the bare
name when the outcome carries no variable label. Under the legend modes
("legend", "legend.bottom") nothing is printed here, because the
variable-label legend (.print_model_var_labels) already carries the
outcome in its Outcome section. Emits a leading blank line so it sits
one line below the table.

## Usage

``` r
.jst_print_outcome_line(data, dv_name, vlmode)
```

## Arguments

- data:

  Pre-conversion label source (the data frame jlm()/jlogistic() captured
  for label lookups).

- dv_name:

  The outcome variable name (the response in the model formula).

- vlmode:

  Resolved variable.id mode.

## Value

Invisibly NULL; called for its printing side effect.
