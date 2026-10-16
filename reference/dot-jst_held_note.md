# Internal helper: the note naming where the other predictors are held

"(line shown at x = 0, g_b = 0)" under a fitted line; under the
predictions at a dummy-coded variable's categories, what is shown is
named instead of the line ("(means shown at x = 0)", Session 360). A
dummy column keeps its name, as in the equation (Session 347).

## Usage

``` r
.jst_held_note(at_vals, what = "line")
```

## Arguments

- at_vals:

  The held values, by model column.

- what:

  Character(1): "line", "means" or "probabilities".

## Value

Character(1), or NULL when nothing is held.
