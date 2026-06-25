# Internal helper: classify a data frame's predominant UDM convention

Walks a data frame's columns via
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md),
counts SPSS-form vs Stata-form UDM-bearing columns, and returns the
convention with the larger count. Returns `NA_character_` when counts
tie or when no columns carry UDM declarations.

## Usage

``` r
.jst_predominant_convention(df)
```

## Arguments

- df:

  A data frame.

## Value

Character scalar: `"spss"`, `"stata"`, or `NA_character_`.
