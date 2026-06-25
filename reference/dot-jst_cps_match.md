# Internal helper: first-match lookup against a CPS rule frame

Internal helper: first-match lookup against a CPS rule frame

## Usage

``` r
.jst_cps_match(rules, conds)
```

## Arguments

- rules:

  A .jst_cps\_\*\_rules data frame.

- conds:

  Named list of column -\> observed value. A rule cell of `"any"`
  matches anything; otherwise an exact match is required.

## Value

The first matching row index, or `NA_integer_`.
