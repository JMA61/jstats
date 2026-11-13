# Printing a saved analysis result

A result kept with `<-` – `m1 <- jlm(...)` – holds the output its
analysis printed, or would have printed under `print = FALSE` or
`joutput("silent")`: typing `m1`, or `print(m1)`, shows it again, as it
was at the call. The parts the result holds are read as before, with
`$`, [`str()`](https://rdrr.io/r/utils/str.html) or
[`jtable()`](https://jma61.github.io/jstats/reference/jtable.md).

## Usage

``` r
# S3 method for class 'jst_desc'
print(x, ...)

# S3 method for class 'jst_freq'
print(x, ...)

# S3 method for class 'jst_multi'
print(x, ...)

# S3 method for class 'jst_ttest'
print(x, ...)

# S3 method for class 'jst_anova'
print(x, ...)

# S3 method for class 'jst_crosstab'
print(x, ...)

# S3 method for class 'jst_corr'
print(x, ...)

# S3 method for class 'jst_lm'
print(x, ...)

# S3 method for class 'jst_logistic'
print(x, ...)

# S3 method for class 'jst_alpha'
print(x, ...)
```

## Arguments

- x:

  A saved result of
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md),
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md),
  [`jmulti()`](https://jma61.github.io/jstats/reference/jmulti.md),
  [`jt()`](https://jma61.github.io/jstats/reference/jt.md),
  [`jaov()`](https://jma61.github.io/jstats/reference/jaov.md),
  [`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md),
  [`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md),
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md),
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
  or [`jalpha()`](https://jma61.github.io/jstats/reference/jalpha.md).

- ...:

  Not used.

## Value

`x`, invisibly.
