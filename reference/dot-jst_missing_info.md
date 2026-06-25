# Internal: read missing-value declarations from a column

Central reading abstraction for the missing-value handling layer. Takes
a column and returns a uniform structure describing the formal
missing-value information attached to it, regardless of whether the
column carries SPSS UDM representation (`na_values` and/or `na_range`
attributes on `haven_labelled_spss`) or Stata UDM representation
(`tagged_na` markers on `haven_labelled` or plain numeric). Downstream
helpers consume this structure rather than reading raw attributes
themselves; this keeps representation- specific knowledge in one place.

## Usage

``` r
.jst_missing_info(col)
```

## Arguments

- col:

  A column from a data frame, possibly with UDM attributes or
  Stata-style missing-value markers.

## Value

`NULL` if the column has no formal UDM declarations. Otherwise a list
with:

- representation:

  `"spss"` or `"stata"`

- na_range:

  Length-2 numeric vector for SPSS range-based missingness, or `NULL`

- codes:

  A data frame with one row per declared code/tag, or `NULL` if only
  `na_range` is present. Columns: `code` (character display form, e.g.
  `"-99"` or `".a"`), `label` (character or `NA`), `source`
  (`"na_values"` or `"tagged_na"`), `numeric` (underlying numeric value;
  `NA` for tagged NAs), `tag` (tag letter for Stata; `NA` for SPSS
  UDMs).

## Details

Label-only detection (values with labels like "Refused" but no formal
declaration) is NOT in scope here – that pattern is handled by
`.jst_scan_coded_missing`'s heuristic branch.
