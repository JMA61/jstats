# Internal: jload()'s note on variables of numbers made text by a few cells

Ruling R31, question 5 (Session 380): the values that are not numbers,
each quoted with its count, then the jload() call as typed with `na =`
naming them, which reads them as missing and the variables as numbers.
It replaces the load scan's block for these variables, whose declaration
left the variable text.

## Usage

``` r
.jst_marker_note(marks, vars, line)
```

## Arguments

- marks:

  From
  [`.jst_csv_type_columns()`](https://jma61.github.io/jstats/reference/dot-jst_csv_type_columns.md)
  or
  [`.jst_marker_columns()`](https://jma61.github.io/jstats/reference/dot-jst_marker_columns.md).

- vars:

  The data frame's variable names, as loaded.

- line:

  The jload() line with `na =`, indented.

## Value

Character(1).
