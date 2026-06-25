# Internal helper: a labelled variable's surviving (non-missing) value labels

Returns the value labels of a haven-labelled column with every code that
is declared missing removed, so the scale-detection helpers judge a
variable on its real response options rather than on missing-value
sentinels mixed into the label set. Declared-missing codes are read
through the central
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
reader, so SPSS-style `na_values` and `na_range` declarations and
Stata-/SAS-style tagged NAs are all handled in one place. (A 1-to-5
agreement item carrying a Refused code of -99 and a Don't-know code of
-98 as declared missings therefore yields the five real scale points,
not seven codes with a gap.)

## Usage

``` r
.jst_surviving_value_labels(col)
```

## Arguments

- col:

  A variable / data-frame column.

## Value

A named numeric vector of surviving value labels (names are the label
texts, values the codes), or `NULL` if the column is not labelled or has
no value labels. Length 0 if every label is a declared missing.
