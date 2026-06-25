# Internal helper: variable label for display, falling back to the name

Used by the `"labels"` variable.id mode, where a variable's label
replaces its name in table rows, table captions, crosstab dimnames, or
(in jplot) axis/legend/facet titles. When the variable carries no
non-empty variable label, its name is returned unchanged. This name
fallback is the only sensible rendering for an unlabelled variable and
is distinct from a mode fallback: `"labels"` is still honored literally
(no switch to a legend), the label slot simply equals the name.

## Usage

``` r
.jst_label_or_name(data, var)
```

## Arguments

- data:

  A data frame.

- var:

  Single variable name (character).

## Value

Single character string: the variable's label if present and non-empty,
otherwise `var`.
