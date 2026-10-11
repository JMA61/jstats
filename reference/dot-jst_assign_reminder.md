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
.jst_assign_reminder(fn_name, data_name, data_kind, typed, landed, lead = TRUE)
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

- lead:

  TRUE when a note of the same call has printed above it: the reminder
  then opens with a blank line, and otherwise does not (voice Rule F: a
  blank line between notes, none before the first). Until Session 353 it
  always opened with one, so a call whose only output was the reminder
  printed a blank first line (the S352 item).

## Value

Character(1) with no trailing newline.
