# Internal helper: the assign-or-lose reminder of jrecode() and jencode()

Both functions return the new values and change nothing, so an
unassigned call drops them; the reminder closes each call's notes at the
standard and full output levels. The line it shows assigns to a variable
of the data frame the call named. An expression in the data's place –
`jencode(mt(), w)` – has no such variable to assign to, and until
Session 343 the line read `mt()$<name> <- jencode(...)`, which is not R
(the S339 item's second half). It now gets the two lines the
registration verbs give: the expression assigned to a name, and the
assignment on that name. A place (`lst$d`) keeps the one line, which
runs.

## Usage

``` r
.jst_assign_reminder(fn_name, data_name, data_kind, typed, landed)
```

## Arguments

- fn_name:

  Character(1); `"jrecode"` or `"jencode"`.

- data_name:

  Character(1); the data frame as the lines name it.

- data_kind:

  What the call gave as its data, as
  [`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)
  reads it.

- typed:

  Character(1); the data argument as typed, for the `"expression"`
  kind's first line.

- landed:

  Character(1); the noun of the closing check line (`"recode"`,
  `"encoding"`).

## Value

Character(1) with a leading newline (voice Rule F) and no trailing one.
