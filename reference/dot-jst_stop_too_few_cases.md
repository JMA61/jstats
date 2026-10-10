# Internal helper: stop when a model has no more cases than coefficients

[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
call this after the Case Processing block and the checks on single
variables, just before the fit. With as many cases as coefficients a
linear model fits every case exactly and has no residual degrees of
freedom: [`lm()`](https://rdrr.io/r/stats/lm.html) returned it, and the
Coefficients table printed NaN standard errors and t values, an empty p
column, "Adjusted R-squared: NaN" and "F-statistic: NaN on 2 and 0 DF,
p-value: " under R's "NaNs produced".
[`glm()`](https://rdrr.io/r/stats/glm.html) on the same cases warned
"fitted probabilities numerically 0 or 1 occurred" dozens of times and
printed an Exp(B) of 62 digits. With fewer cases than coefficients some
coefficients cannot be estimated at all. One stop now, naming both
counts, and how the other cases went when some did (Session 347; the
S346 item).

## Usage

``` r
.jst_stop_too_few_cases(sample_info, n_coef, what)
```

## Arguments

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- n_coef:

  Integer(1); the coefficients the model would estimate, the intercept
  included (the columns of its model matrix).

- what:

  Character(1); "A regression" or "A logistic regression".

## Value

Invisibly `NULL` when there are more cases than coefficients; otherwise
never returns.
