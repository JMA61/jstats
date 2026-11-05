# Internal helper: the display string of each of jfreq()'s categories

Every category of a labelled variable – the codes the cases hold and the
labelled values no case holds – formatted under the call's value.id mode
in ONE call to
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md),
so that a label two codes share shows each code under "labels" ("1:
Other", "2: Other"). The strings are the levels jfreq() tabulates by,
one per code, so they must differ: where the 40-column cap still cuts
two alike (two long text codes under "values", say) those two are shown
whole, and as a last resort numbered. Until Session 407 the rows were
the distinct display strings, so two codes that printed alike were
counted as one row (the (S399) colliding-labels item).

## Usage

``` r
.jst_freq_displays(codes, val_labels, mode)
```

## Arguments

- codes:

  The categories' codes, distinct; numeric or character.

- val_labels:

  The variable's value labels, or NULL.

- mode:

  The resolved value.id mode.

## Value

Character, one distinct string per code.
