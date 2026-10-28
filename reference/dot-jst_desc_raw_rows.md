# Internal helper: per-variable statistics, unrounded, in jdesc()'s raw shape

One row per variable – variable, total, n_valid, n_missing, min, max,
mean, sd, every number unrounded – with the variables' labels as a keyed
`labels` attribute: the shape of jdesc()'s descriptives_raw (the
return-shape audit, Session 71), so a table reads M and SD the same way
whichever result they come from. Session 399 (Capability Slate T's build
0): jcorr()'s M and SD, on the numeric values its correlations read,
each variable on its own cases.

## Usage

``` r
.jst_desc_raw_rows(cols, vars, label_src)
```

## Arguments

- cols:

  A data frame or list of numeric vectors, one per variable.

- vars:

  Character; the variables, in order.

- label_src:

  The data frame the labels are read from.

## Value

A data frame, as described.
