# Internal: the load scan's findings on one text variable

Slate E5 (the S372 item, lean 5): a value of a text variable is reported
`label_only` when its value label suggests missingness, and `suspected`
when the value itself does (`"UNKNOWN"`, `"Refused"`) – both read by the
word list
([`.jst_label_suggests_missing()`](https://jma61.github.io/jstats/reference/dot-jst_label_suggests_missing.md))
– and `suspected` too when it differs from a value the variable declares
only in letter case or outer spaces (Jeff, S373;
[`.jst_text_near_misses()`](https://jma61.github.io/jstats/reference/dot-jst_text_near_misses.md),
the helper jdeclare_missing()'s note uses). A value the variable already
declares missing, and a blank cell, are not reported: blanks are
reported, never assumed missing (Cross-cutting 7 (3)), by jfreq() and
jscreen().

## Usage

``` r
.jst_scan_text_missing(col, vname)
```

## Arguments

- col:

  The variable (character, or character-backed labelled).

- vname:

  Its name.

## Value

A list of findings, in the scan's form, with `text = TRUE`; values in
radix order.
