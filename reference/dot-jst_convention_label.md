# Internal helper: user-facing style label for a UDM convention

Maps a convention token to the locked user-facing vocabulary (the
MISSING-VALUE-TERMS rule, S36): "SPSS-style" / "Stata-style" /
"SAS-style". Shared by the joptions environment-scan notice and
jdeclare_missing's post-declaration mismatch notice so the two render
identically.

## Usage

``` r
.jst_convention_label(convention)
```

## Arguments

- convention:

  Character vector of convention tokens ("spss", "stata", "sas").

## Value

Character vector of display labels; `NA` for unrecognized or `NA` input.
