# Internal: convert SAS-style missing values to Stata-style in a data frame

Walks the columns of `data`, converting any SAS-style missing values
(`.A`, `.B`, ..., stored as `haven::tagged_na("A")` etc.) to their
Stata-style equivalents (`.a`, `.b`, ...) in both cell values and the
`val_labels` attribute. haven's `write_dta()` errors on SAS-style
markers in either location (Stata's format is lowercase-only), so this
conversion runs unconditionally in
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md)'s .dta
branch before `write_dta` is called.

## Usage

``` r
.jst_lowercase_tagged_na_df(data)
```

## Arguments

- data:

  A data frame.

## Value

List with two elements: `data` (the data frame with SAS-style markers
converted to Stata-style) and `n_changed` (integer count of columns
touched).

## Details

A column is counted in `n_changed` when any SAS-style marker was
converted – in cells, in `val_labels`, or both. Columns already in
Stata-style form pass through unchanged and are not counted. Non-double
columns are skipped (Stata-style missing values exist only on doubles).
