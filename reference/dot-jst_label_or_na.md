# Internal helper: a label, or NA where there is none

A stored label is `NA` when the value has no label, and an empty label
counts as none, as
[`.jst_format_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_format_value_labels.md)
and
[`.jst_udm_row_label()`](https://jma61.github.io/jstats/reference/dot-jst_udm_row_label.md)
count it. Session 399 (Capability Slate T's build 0): the Label columns
of jfreq()'s Missing rows.

## Usage

``` r
.jst_label_or_na(x)
```

## Arguments

- x:

  A character vector of labels (or NA).

## Value

Character, `NA` for each missing or empty label.
