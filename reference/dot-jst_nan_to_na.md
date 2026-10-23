# Internal helper: NaN made NA

[`is.na()`](https://rdrr.io/r/base/NA.html) is TRUE for NaN, so the
pipeline's masks and the Case Processing block count a NaN cell as
missing, but [`factor()`](https://rdrr.io/r/base/factor.html) and
[`haven::as_factor()`](https://forcats.tidyverse.org/reference/as_factor.html)
make it a level of its own, "NaN": jcrosstab() counted in its table a
case its Analysis N had excluded (Session 394, found beside the (S392)
infinite-value item). A variable stored as double, labelled or not, has
its NaN cells set to NA; anything else is returned as it came.

## Usage

``` r
.jst_nan_to_na(x)
```

## Arguments

- x:

  A variable.

## Value

The variable.
