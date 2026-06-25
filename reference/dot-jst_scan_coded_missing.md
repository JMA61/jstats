# Internal: scan for coded missing values and report findings

Internal: scan for coded missing values and report findings

## Usage

``` r
.jst_scan_coded_missing(df, obj_name, scan_udm = TRUE)
```

## Arguments

- scan_udm:

  Logical. When `FALSE`, the haven `na_values` and `na_range` branches
  are skipped (only the suspicious-values heuristic runs). Set to
  `FALSE` when called after
  [`.jst_handle_udms()`](https://jma61.github.io/jstats/reference/dot-jst_handle_udms.md)
  has already produced its narrative for `.sav` loads, to avoid
  duplicate output. The heuristic branch always excludes values that are
  formally declared in `na_values` or `na_range` on the variable, so
  passing `scan_udm = FALSE` produces no UDM-related output – neither
  tabular nor flagged-as-suspected.
