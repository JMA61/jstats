# Internal helper: print the VIF table and its notes

The VIF table of
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md),
with its brief interpretation under it (Session 346: printed except at
the minimal level). Without a set of dummy variables it is the table of
each predictor's VIF as before. With one (Session 375), the table takes
`car::vif()`'s columns – GVIF, Df and GVIF^(1/(2*Df)) – with one row per
predictor, the set's dummy columns sharing one, and two lines under it
say what the rows are; a predictor's note then fires when
GVIF^(1/(2*Df)) squared passes 10, as a VIF's does.

## Usage

``` r
.jst_print_vif(vif_values, gvif = NULL)
```

## Arguments

- vif_values:

  Named numeric; each column's VIF.

- gvif:

  The data frame
  [`.jst_compute_gvif()`](https://jma61.github.io/jstats/reference/dot-jst_compute_gvif.md)
  returns, or `NULL`.

## Value

Invisible NULL.
