# Internal helper: the labelled VALID values no case holds

jfreq()'s zero rows on the Valid side (Session 348, ruling R4 (b)). From
a variable's value labels, the values that are not among those observed
in the analysis pool and that the variable does not declare missing – a
declared code, a value inside a declared range, or a Stata-style or
SAS-style marker (whose label value is NA, so it never reaches here). A
label on a blank text value is left out: blank cells are one category, ,
which a zero row would duplicate.

## Usage

``` r
.jst_freq_empty_labels(labs, observed, mi, text = FALSE)
```

## Arguments

- labs:

  The variable's value labels
  ([`labelled::val_labels()`](https://larmarange.github.io/labelled/reference/val_labels.html)).

- observed:

  The values present in the pool, as the caller holds them (numeric, or
  character when `text = TRUE`).

- mi:

  The variable's
  [`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
  (or NULL).

- text:

  Logical; TRUE for a character-backed labelled variable.

## Value

The values, in label order, of the same type as `observed`.
