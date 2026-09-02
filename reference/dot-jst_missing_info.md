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
.jst_missing_info(col, observed = FALSE)
```

## Arguments

- col:

  A column from a data frame, possibly with UDM attributes or
  Stata-style missing-value markers.

- observed:

  Logical. When `TRUE`, additionally enumerate the distinct values
  actually PRESENT in the column that fall inside a declared `na_range`,
  returned as `range_values`. Defaults to `FALSE` because that
  enumeration reads the column's data (cost proportional to its length),
  while every other component of the return is an attribute read.
  Callers that need only the declaration – jsave's pre-flight, jload's
  narrative, jconvert, the CPS renderers – leave it `FALSE` and pay
  nothing.

## Value

`NULL` if the column has no formal UDM declarations. Otherwise a list
with:

- representation:

  `"spss"` or `"stata"` – the PHYSICAL structure (na_values metadata vs
  tagged_na markers). Deliberately binary: SAS-form is structurally
  Stata-form (Decision 13), so structural consumers (conversion loops,
  UDM-to-NA application) key on this and never see "sas".

- convention:

  `"spss"`, `"stata"`, `"sas"`, or `NA_character_` – the user-facing
  CONVENTION, refined from tag letter case: all-lowercase tags read as
  Stata-form, all-uppercase as SAS-form, mixed case as `NA` (ambiguous;
  Decision 13's rule – such a column is skipped by convention counting
  and does not engage the resolver's column level). Always `"spss"` for
  SPSS-representation columns.

- na_range:

  Length-2 numeric vector for SPSS range-based missingness, or `NULL`

- codes:

  A data frame with one row per declared code/tag, or `NULL` if only
  `na_range` is present. Columns: `code` (character display form, e.g.
  `"-99"` or `".a"`), `label` (character or `NA`), `source`
  (`"na_values"` or `"tagged_na"`), `numeric` (underlying numeric value;
  `NA` for tagged NAs), `tag` (tag letter for Stata; `NA` for SPSS
  UDMs).

- range_values:

  Only when `observed = TRUE` and an `na_range` is declared: a data
  frame of the DISTINCT observed in-band values, same columns as `codes`
  (with `source = "na_range"`), ascending by value, carrying no counts –
  consumers keep their own counting logic, exactly as they do for
  `codes`. Values that are also declared discretely in `na_values` are
  excluded, so the two components never describe the same cell twice. A
  zero-row data frame means the band is declared but no in-band value
  occurs; `NULL` means the enumeration was not requested, or no band is
  declared.

## Details

Label-only detection (values with labels like "Refused" but no formal
declaration) is NOT in scope here – that pattern is handled by
`.jst_scan_coded_missing`'s heuristic branch.

## Why codes is not extended

`codes` carries DECLARATION-SLOT semantics – consumers such as jsave's
.sav pre-flight, jconvert's letter cap and its SPSS-to-Stata ordering,
and jdeclare_missing's drop notice read `nrow(codes)` as "how many
discrete codes has the user declared". Folding observed in-band values
into `codes` would take a range-bearing column from zero declared codes
to however many happen to be present, and those consumers would then
refuse a file that saves correctly today. Observed values are therefore
a separate component, never a longer `codes`.
