# Internal helper: choose an axis label for a variable

Returns the variable's label (from labelled::var_label) if one is set
and fits within `max_len` characters. Truncates with three trailing
periods if the label exceeds `max_len`. Falls back to the variable name
when no label is present. Since Session 390 the length is measured and
cut in display columns
([`.jst_dw()`](https://jma61.github.io/jstats/reference/dot-jst_dw.md),
[`.jst_cut_width()`](https://jma61.github.io/jstats/reference/dot-jst_cut_width.md)):
a Chinese, Japanese or Korean character is about twice as wide as a
Latin letter on an axis too, and the count of characters let such a
label run to twice the length.

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
