# Internal: build jsave's case-correction note for .dta export

Produces the informational note emitted by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when
SAS-style missing values in the data frame have been converted to
Stata-style for the .dta format. haven's `write_dta()` errors on
SAS-style markers, so the conversion is necessary for the write to
succeed; the note simply tells the user it happened. Suppressed at
`joutput("minimal")` and `joutput("standard")`; shown at
`joutput("full")` only.

## Usage

``` r
.jst_jsave_dta_case_correction_note(n_changed)
```

## Arguments

- n_changed:

  Integer. Number of columns whose SAS-style missing values were
  converted.

## Value

Character scalar, or `NULL` when the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md) level
suppresses the note or when no conversion happened.
