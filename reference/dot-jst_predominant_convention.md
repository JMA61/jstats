# Internal helper: classify a data frame's predominant UDM convention

Thin wrapper over
[`.jst_convention_census()`](https://jma61.github.io/jstats/reference/dot-jst_convention_census.md)
returning only the verdict, for callers that need no counts or
unanimity.

## Usage

``` r
.jst_predominant_convention(df)
```

## Arguments

- df:

  A data frame.

## Value

Character scalar: `"spss"`, `"stata"`, `"sas"`, or `NA_character_`.
