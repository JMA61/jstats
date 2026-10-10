# Internal helper: compute the terms built from the focal variable on a plot's grid

A fitted-line plot moves one predictor along its axis and holds the
others at the values
[`.jst_resolve_at()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_at.md)
gives. A term computed from the moving predictor – `I(x^2)`,
`log(x + 5)`, `I(x * z)` with `z` held – is a column of its own in the
model, and until Session 347 it was held too: at 0 by default, so the
line for `y ~ x + I(x^2)` was the straight line `b0 + b1 x`, subtitled
"(line shown at I(x^2) = 0)". Such a term is now computed from the grid.
Only terms built from arithmetic, comparisons and elementwise functions
are computed; a term whose value depends on the whole sample
(`scale(x)`, `poly(x, 2)`) or that names a variable that is neither held
nor a single number in the formula's environment is held as before.

## Usage

``` r
.jst_terms_on_grid(newdata, focal, at_vals, enclos = NULL)
```

## Arguments

- newdata:

  The grid: the focal variable's values, the held values.

- focal:

  Character(1); the focal variable.

- at_vals:

  The held values, by model column.

- enclos:

  The formula's environment, for a constant a term names.

## Value

A list: `newdata`, with the terms computed, and `computed`, their names
(to leave out of the held-at note).
