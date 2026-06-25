# Internal: inspect a data frame for UDM-bearing columns and optionally convert UDM cells to NA

Walks the columns of `df`, calling
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
on each to discover formal user-defined missing-value declarations.
Captures per-variable information into a list entry used downstream by
the narrative formatter. Covers both SPSS UDM representation
(`na_values` and/or `na_range` on `haven_labelled_spss`) and Stata UDM
representation (`tagged_na` markers on `haven_labelled`).

## Usage

``` r
.jst_handle_udms(df, preserve.udm)
```

## Value

A list with elements `df` (possibly modified) and `udm_info` (list of
per-variable info; empty list if no UDM- bearing columns were found).
Each `udm_info` entry is a list with `var` (variable name) and `info`
(the
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
return value for that column).

## Details

When `preserve.udm = FALSE`, additionally converts UDM cells to `NA` and
strips the corresponding metadata. For SPSS columns this strips
`na_values` and `na_range`; for Stata columns
[`haven::zap_missing()`](https://haven.tidyverse.org/reference/zap_missing.html)
converts Stata-style missing-value cells to plain NA. In both cases the
column's other attributes (value labels for non-missing codes, variable
label, class) are preserved.
