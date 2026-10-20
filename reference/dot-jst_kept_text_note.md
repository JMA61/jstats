# Internal: jload()'s note on variables kept as text

Ruling R31, questions 1 and 2 (Session 380): a CSV variable of numbers
kept as text because a number would change a value – a leading zero it
would drop, or more than the 15 digits it holds exactly. One variable:
the sentence and, for a leading zero, the as.numeric() line. Several: a
line each, then the lines for those with a leading zero (converting a
long ID would destroy it, so none is offered).

## Usage

``` r
.jst_kept_text_note(kept, vars, obj_name)
```

## Arguments

- kept:

  From
  [`.jst_csv_type_columns()`](https://jma61.github.io/jstats/reference/dot-jst_csv_type_columns.md).

- vars:

  The data frame's variable names, as loaded.

- obj_name:

  The data frame's name.

## Value

Character(1).
