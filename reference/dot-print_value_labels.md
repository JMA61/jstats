# Internal helper: print a value-label legend block

Companion to `.print_var_labels` for the `value.id` legend modes. Emits
one line per variable that carries value labels, in the form
`varname: code = label, code = label, ...` under a `Value Labels:`
header, matching the variable-label block's header + indented-lines +
blank line structure. One line per variable (locked design); legend
lines are not table cells, so they are not width-capped. Variables
without value labels contribute nothing; if no variable carries any,
nothing is printed.

## Usage

``` r
.print_value_labels(data, var_names)
```

## Arguments

- data:

  A data frame (or pre-conversion label source) whose columns may carry
  value labels
  ([`labelled::val_labels`](https://larmarange.github.io/labelled/reference/val_labels.html)).

- var_names:

  Character vector of variable names to document, in order.
