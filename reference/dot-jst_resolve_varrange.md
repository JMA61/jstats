# Internal helper: resolve variable names from enquos, expanding colon ranges

Handles both explicit variable names (var1, var2, var3) and colon
notation (var1:var3) which expands to all columns between the two
endpoints in column order. Named arguments (e.g. min.valid, var.label)
are excluded.

## Usage

``` r
.jst_resolve_varrange(quos_list, data, fn_name, data_name = NULL)
```

## Arguments

- quos_list:

  A list of quosures from rlang::enquos(...).

- data:

  The data frame to resolve column names against.

- fn_name:

  Character. The calling function name for error messages.

## Value

A list with two components:

- var_names:

  Character vector of all resolved variable names.

- label_parts:

  Character vector of label-friendly descriptions, using "X to Y" for
  colon ranges and plain names for explicit variables.
