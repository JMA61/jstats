# Internal helper: the residuals of a jt() or jaov() result

The `residuals` element, which results made before Session 375 do not
carry; for one of those, the stop that asks for the call again.

## Usage

``` r
.jst_result_residuals(x, fn)
```

## Arguments

- x:

  A `jst_ttest` or `jst_anova` result.

- fn:

  Character(1); `"jt"` or `"jaov"`.

## Value

Numeric vector.
