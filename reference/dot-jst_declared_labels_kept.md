# Internal helper: the labels of declared missing values a new set leaves out (ruling R37)

Ruling R37 (Session 391; Jeff: "Yes to your recommendation"): labels =
replaces the labels of the values it names and of every value that is
not a declared missing value, and a declared missing value keeps its
label unless the new set names it – as jrecode()'s labels = keeps them,
with its note. Until then a replacement set cleared them, so jfreq()
printed `-99 (no label)` where it had printed `-99 ["Refused"]`, and a
Stata-style or SAS-style marker that no case carries, declared only by
its label, was no longer declared at all. Declared means a code among
the variable's na_values or inside its na_range, or a marker (a tagged
NA) among its labels. A code is named by its value, a marker by its
letter.

## Usage

``` r
.jst_declared_labels_kept(x, parsed_labels)
```

## Arguments

- x:

  The variable before the new labels.

- parsed_labels:

  The new set, as
  [`.jst_parse_labels()`](https://jma61.github.io/jstats/reference/dot-jst_parse_labels.md)
  gives it.

## Value

The labels to keep, a named vector of `x`'s labels, or NULL.
