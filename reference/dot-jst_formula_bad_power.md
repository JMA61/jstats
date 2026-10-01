# Internal helper: find a power in a formula that terms() refuses

Outside [`I()`](https://rdrr.io/r/base/AsIs.html), `^` in a formula is
the interaction operator, and
[`terms()`](https://rdrr.io/r/stats/terms.html) accepts only a number of
1 or more after it, stopping with "invalid power in formula" on anything
else: `x^k` with `k` a name, `x^-1`, `x^(2)`. This walks the right-hand
side through the formula operators, as
[`.jst_formula_bare_powers()`](https://jma61.github.io/jstats/reference/dot-jst_formula_bare_powers.md)
does, and returns the first `^` whose power
[`terms()`](https://rdrr.io/r/stats/terms.html) would refuse, so the
caller can stop in house voice instead (Session 323). Reading `k` and
fitting the power would exceed
[`lm()`](https://rdrr.io/r/stats/lm.html), which refuses the same
formula.

## Usage

``` r
.jst_formula_bad_power(formula)
```

## Arguments

- formula:

  The analysis formula as typed.

## Value

NULL when there is none; otherwise a list of `typed` (the term as
written), `base` (the term raised, parentheses stripped), `base_typed`
(the same as written), `power` (the power as written) and `single` (TRUE
when the base is a single term, not a sum or product of terms).
