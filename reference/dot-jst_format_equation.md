# Internal helper: format a regression equation for plot subtitles

Builds a short equation string from a coefficient vector for use as a
plot subtitle. Truncates to `max_terms` predictors and joins them with
appropriate sign characters.

## Usage

``` r
.jst_format_equation(coefs_vec, dv_name, max_terms = 3)
```

## Arguments

- coefs_vec:

  Named numeric vector of regression coefficients (intercept first).

- dv_name:

  Character. The dependent variable name used at the left-hand side of
  the equation.

- max_terms:

  Integer. Maximum number of predictor terms to include. Default 3;
  additional terms are summarized as `...`.

## Value

A character string of the formatted equation.

## Details

The terms are named as the coefficient table names them (Session 347):
without the backticks R puts around a computed term or a name with a
space (`` `I(x^2)` ``, `` `my var` ``), and an interaction with `" * "`
for R's `":"`. A dummy column keeps its name (`g_Mid`), which the line's
"(line shown at g_Mid = 0, ...)" uses too.
