# Internal helper: compute VIF for a fitted linear model

Computes Variance Inflation Factors from the model matrix correlation
structure. Returns a named numeric vector of VIF values for each
predictor (excluding the intercept). Returns NULL for bivariate models
(only one predictor) since VIF is not meaningful.

## Usage

``` r
.jst_compute_vif(model)
```

## Arguments

- model:

  A fitted `lm` object.

## Value

Named numeric vector of VIF values, or NULL for bivariate models.
