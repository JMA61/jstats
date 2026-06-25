# Internal helper: choose an axis label for a variable

Returns the variable's label (from labelled::var_label) if one is set
and fits within `max_len` characters. Truncates with three trailing
periods if the label exceeds `max_len`. Falls back to the variable name
when no label is present.

## Usage

``` r
.jst_short_label(x, name, max_len = 35)
```

## Arguments

- x:

  A variable (vector), possibly haven-labelled.

- name:

  Character. The variable name to fall back to if no label.

- max_len:

  Integer. Maximum label length before truncation. Default 35.

## Value

A character string suitable for use as an axis label.
