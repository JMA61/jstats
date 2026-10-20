# Internal helper: does this analysis call print?

The per-call `print` argument of the analysis functions, read against
the `joutput("silent")` level (Capability Slate C3, Session 378; the
Session 70 item): `TRUE` prints, `FALSE` does not, and `NULL` (the
default) prints unless the level is silent.

## Usage

``` r
.jst_print_on(print)
```

## Arguments

- print:

  The call's `print` argument.

## Value

Logical(1).
