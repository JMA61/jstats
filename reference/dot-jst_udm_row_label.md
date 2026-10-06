# Internal helper: render one missing-value row label

The established form for a missing-value row in jfreq and in
[`.jst_cps_var_rows()`](https://jma61.github.io/jstats/reference/dot-jst_cps_var_rows.md):
`-99 ["Refused"]` when the value carries a label, `-99 (no label)` when
it does not. Shared so declared codes, Stata tags, and observed in-band
values all render identically – nothing new is invented for the in-band
rows.

## Usage

``` r
.jst_udm_row_label(code_display, label, unlabelled = "note")
```

## Arguments

- code_display:

  Character display form of the value.

- label:

  Character label; `NA`, `""`, `NULL` or a zero-length vector for none.

- unlabelled:

  What a value with no label gets: `"note"`, the table rows'
  `-99 (no label)`; or `"bare"`, the value alone, for a message that
  says "no label" in its own way or not at all.

## Value

A single character string.

## Details

Since Session 345 (the S319 item) it is also the ONE place the bracketed
form is built. The Case Processing rows, the load narrative, the
declaration confirmation and its drop notice,
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)'s
report and
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)'s
notes each wrote their own
[`sprintf()`](https://rdrr.io/r/base/sprintf.html); they call this, and
`unlabelled` carries the one difference between them.
