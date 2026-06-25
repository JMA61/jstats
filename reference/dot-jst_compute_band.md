# Internal helper: compute prediction interval or +/- t\*SEE band for a bivariate regression

Internal helper: compute prediction interval or +/- t\*SEE band for a
bivariate regression

## Usage

``` r
.jst_compute_band(plot_df, band)
```

## Arguments

- plot_df:

  Data frame with columns x and y.

- band:

  Either "pi" or "see".

## Value

Data frame with columns x, fit, lwr, upr.
