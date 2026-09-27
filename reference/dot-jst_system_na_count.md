# Internal helper: count a column's true system-missing cells

Counts the cells missing in the raw data, leaving out declared missing
values: a live labelled_spss column reports its declared codes and range
cells as NA under [`is.na()`](https://rdrr.io/r/base/NA.html), and a
Stata- or SAS-form column reports its marker cells the same way. Shared
by the System/NA row of .jst_cps_var_rows() and the "Has system NAs"
flag in .jst_print_case_processing(), so the two cannot disagree
(AUDIT-007, Session 315).

## Usage

``` r
.jst_system_na_count(col, mi = NULL)
```

## Arguments

- col:

  A column.

- mi:

  The column's .jst_missing_info() result, or `NULL`.

## Value

An integer count.
