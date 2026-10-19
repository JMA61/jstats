# Internal helper: Cramer's V

The effect size of a chi-square test of independence (Session 375):
`sqrt(chi2 / (n * (k - 1)))`, `k` the smaller of the table's two
dimensions; in a 2 x 2 table, phi without its sign.

## Usage

``` r
.jst_cramers_v(chi2, n, dims)
```

## Arguments

- chi2:

  The Pearson chi-square.

- n:

  The table's total.

- dims:

  The table's dimensions.

## Value

Numeric(1); NA when the table has fewer than two rows or columns.
