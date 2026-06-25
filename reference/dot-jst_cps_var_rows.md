# Internal helper: per-variable source/pool missing rows for the CPS bottom

Computes, for one analysis variable, the per-code (and System/NA) counts
in the source (full original) and pool (surviving rows) columns. Counts
come from the pre-masking columns so SPSS-form UDM codes are still live
values; pool counts are post-filter-correct (this is also why the
Session 29 pre/post UDM count quirk does not affect the CPS bottom).

## Usage

``` r
.jst_cps_var_rows(pre_col, pool_col, mi)
```

## Arguments

- pre_col:

  Pre-masking original column (full N).

- pool_col:

  Pre-masking column restricted to surviving rows.

- mi:

  [`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
  for the column, or NULL.

## Value

data.frame(code_label, src, pool); empty if no missingness.
