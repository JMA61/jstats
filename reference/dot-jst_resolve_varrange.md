# Internal helper: resolve variable names from enquos, expanding colon ranges

Handles both explicit variable names (var1, var2, var3) and colon
notation (var1:var3) which expands to all columns between the two
endpoints in column order. Named arguments (e.g. min.valid, var.label)
are excluded.

## Usage

``` r
.jst_resolve_varrange(
  quos_list,
  data,
  fn_name,
  data_name = NULL,
  default_used = FALSE
)
```

## Arguments

- quos_list:

  A list of quosures from rlang::enquos(...).

- data:

  The data frame to resolve column names against.

- fn_name:

  Character. The calling function name for error messages.

- data_name:

  Character. The data frame's name, for messages.

- default_used:

  Logical. `TRUE` when the data frame came from the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default;
  passed to
  [`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md),
  which words an endpoint that is not found (Session 343).

## Value

A list with two components:

- var_names:

  Character vector of all resolved variable names.

- label_parts:

  Character vector of label-friendly descriptions, using "X to Y" for
  colon ranges and plain names for explicit variables.
