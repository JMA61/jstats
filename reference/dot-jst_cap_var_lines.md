# Internal: cap an own-line variable list at max_show, with "...and N more"

Takes already-built per-variable display lines (e.g. " Income: 4 codes")
and returns them unchanged when there are at most `max_show`, otherwise
the first `max_show` followed by a " ...and N more" tail. The four-space
indent matches the per-variable lines jconvert and jsave build.

## Usage

``` r
.jst_cap_var_lines(var_lines, max_show = 10L)
```

## Arguments

- var_lines:

  Character vector of pre-built, indented per-variable lines.

- max_show:

  Integer. Maximum lines to show before truncating (default 10).

## Value

Character vector, possibly truncated with a tail line.
