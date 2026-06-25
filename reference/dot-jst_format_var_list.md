# Internal: format a character vector as a comma-separated list with truncation

Renders a vector of variable names (or any character vector) as a single
comma-separated string, truncating after `max_show` entries with a
`"... and N more"` suffix. Used by jsave's pre-flight error messages so
the .sav, .dta, and .xpt code paths share one truncation convention.

## Usage

``` r
.jst_format_var_list(vars, max_show = 10L)
```

## Arguments

- vars:

  Character vector of names to render.

- max_show:

  Integer. Maximum number of names to show before truncating. Default
  `10L`.

## Value

Character scalar. Empty string if `vars` is empty.
