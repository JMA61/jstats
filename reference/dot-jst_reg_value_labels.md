# Internal helper: value labels for a dummy registration's categories

The one lookup behind a coefficient-table header, its category rows, and
the absent-category note (Session 306), so the three cannot label a
category three ways. A factor or character registration is labeled from
its own category values (Session 305, AUDIT-037 rider): the column in
hand is the post-filter frame's, and a synthetic 1..k built from it
shifted every label after a filtered-out category onto the wrong row.
The other types read the column's value labels through
[`.jst_var_value_labels()`](https://jma61.github.io/jstats/reference/dot-jst_var_value_labels.md).

## Usage

``` r
.jst_reg_value_labels(reg, col)
```

## Arguments

- reg:

  A registration object (`var_type`, `codes`, `labels`, optionally
  `values`).

- col:

  The variable's column: the label source for the non-position types,
  and the reconstruction source for a factor or character registration
  saved without `values`.

## Value

A named vector in val_labels() form (names are the labels, values the
codes), or NULL.
