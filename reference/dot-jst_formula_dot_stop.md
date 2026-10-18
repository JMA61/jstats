# Internal helper: refuse the dot in a formula (ruling R24)

lm() reads `y ~ .` as every other column of the data. jstats does not
(Jeff, S371: most data sets hold dates, IDs and categorical variables
needing recoding first, and a dot typed by mistake would give a long,
meaningless output). Refused in every formula function with the Rule AK
template; the sentence names what the function takes on the side the dot
was typed.

## Usage

``` r
.jst_formula_dot_stop(formula, fn)
```

## Arguments

- formula:

  The formula as typed.

- fn:

  The user-facing function name.

## Value

`invisible(NULL)`, or stops.
