# Internal helper: a labelled variable's normalized non-missing label set

The set of surviving (non-missing) value-label texts, trimmed and case-
folded, sorted and de-duplicated. This is the unit the Likert battery
test compares between adjacent columns: two columns belong to the same
battery when their normalized label sets are equal, regardless of which
code each label is mapped to (so a reverse-keyed sibling, which shares
the same answer words on a flipped code mapping, still matches).

## Usage

``` r
.jst_nonmissing_label_set(col)
```

## Arguments

- col:

  A variable / data-frame column.

## Value

A character vector (sorted, unique, lower-cased, trimmed) of the
surviving label texts, or `character(0)`.
