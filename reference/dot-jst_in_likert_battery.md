# Internal helper: does a column sit in a contiguous Likert battery?

The sibling-aware half of the Likert sufficient discriminator. A column
is part of a battery when at least one IMMEDIATELY ADJACENT column (the
one to its left or right in data-frame column order) shares its
normalized non- missing label set (see
[`.jst_nonmissing_label_set()`](https://jma61.github.io/jstats/reference/dot-jst_nonmissing_label_set.md)).
Adjacency uses the column's position in the named frame fetched by
`data_name`; the run breaks at the first neighbour with a different
label set, so an adjacent same-size nominal or a different-scale battery
is naturally excluded. Two matching columns are enough (a run of length
2 or more). Category count plays no part – the match is on the
answer-word set, not the number of categories.

## Usage

``` r
.jst_in_likert_battery(col, var_name = NULL, data_name = NULL)
```

## Arguments

- col:

  The column under test.

- var_name:

  Character string naming the column, or NULL.

- data_name:

  Character string naming the data frame, or NULL.

## Value

TRUE if the column is part of an adjacent same-label-set run of length 2
or more, FALSE otherwise.

## Details

The frame is fetched by name from the global environment (and the
attached search path); when `var_name` or `data_name` is absent, the
named object is not a data frame, the column is not found in it, or the
column has no surviving labels, the test returns FALSE and the caller
falls back to the anchor branch. A battery member therefore needs the
resolver to have been given the variable and frame identity (jscreen
always supplies both); a bare `.jst_is_likert(x)` relies on anchors
alone. The name-based fetch can miss when the frame is local to a
calling function rather than global, a tolerated gap: anchors still
carry English scales and
[`jlikert()`](https://jma61.github.io/jstats/reference/jlikert.md) is
always available.
