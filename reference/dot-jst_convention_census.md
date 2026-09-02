# Internal helper: census a data frame's UDM conventions

Walks a data frame's columns via
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
and tallies countable columns by convention (`"spss"`, `"stata"`,
`"sas"`; ambiguous mixed-case columns are skipped).

## Usage

``` r
.jst_convention_census(df)
```

## Arguments

- df:

  A data frame.

## Value

A list with `counts` (named integer vector: spss, stata, sas),
`predominant` (the strict-plurality winner, or `NA_character_` on a
top-count tie or zero countable columns), and `unanimous` (`TRUE` when
exactly one convention has a nonzero count; `FALSE` otherwise, including
the zero-column case).
