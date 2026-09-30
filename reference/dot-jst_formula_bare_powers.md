# Internal helper: find a single term raised to a power outside I()

In a model formula, `^` is the operator for interactions up to that
order, not arithmetic: `(a + b + c)^2` is the three main effects and
their two-way interactions. Applied to a single term the operator
expands to the term itself, so `y ~ x + x^2` fits x alone and R says
nothing. This walks the right-hand side through the formula operators
only (a function call such as [`I()`](https://rdrr.io/r/base/AsIs.html)
or [`log()`](https://rdrr.io/r/base/Log.html) is arithmetic, so the walk
stops there) and collects every single term – a variable, or a call that
is not itself a formula operator, parentheses stripped – raised to a
whole-number power of 2 or more. A power of a sum, `(a + b)^2`, and
`.^2` are legitimate formula R and are not collected. (Session 321.)

## Usage

``` r
.jst_formula_bare_powers(formula)
```

## Arguments

- formula:

  The analysis formula as typed, before the transform resolver rewrites
  it.

## Value

A list with one element per term found, each a list of `typed` (the term
as written, e.g. `"x^2"`), `base` (the single term, parentheses
stripped) and `power` (an integer); an empty list when there is none or
the formula is not two-sided.
