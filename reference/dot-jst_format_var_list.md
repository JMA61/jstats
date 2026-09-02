# Internal: format a character vector as a comma-separated list with truncation

Renders a vector of variable names (or any character vector) as a single
comma-separated string, truncating after `max_show` entries with a
`"... and N more"` suffix. Used by jsave's pre-flight error messages so
the .sav, .dta, and .xpt code paths share one truncation convention.

## Usage

``` r
.jst_format_var_list(vars, max_show = 10L, and = FALSE)
```

## Arguments

- vars:

  Character vector of names to render.

- max_show:

  Integer. Maximum number of names to show before truncating. Default
  `10L`.

- and:

  Logical. When `TRUE` and the list is not truncated, the final name is
  joined with `"and"` ("A and B"; "A, B, and C" at three or more, Oxford
  comma per Rule A). Default `FALSE`, the comma-only form every pre-S227
  caller expects. A truncated list is unaffected either way – its "...
  and N more" tail already supplies the conjunction.

## Value

Character scalar. Empty string if `vars` is empty.
