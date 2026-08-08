# Internal helper: render one missing-value row label

The established form for a missing-value row in jfreq and in
[`.jst_cps_var_rows()`](https://jma61.github.io/jstats/reference/dot-jst_cps_var_rows.md):
`-99 ["Refused"]` when the value carries a label, `-99 (no label)` when
it does not. Shared so declared codes, Stata tags, and observed in-band
values all render identically – nothing new is invented for the in-band
rows.

## Usage

``` r
.jst_udm_row_label(code_display, label)
```

## Arguments

- code_display:

  Character display form of the value.

- label:

  Character label, or `NA` / `""` for none.

## Value

A single character string.
