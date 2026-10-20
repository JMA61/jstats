# Internal: jload()'s note on variables of numbers made text by a few cells

Ruling R31, question 5 (Session 380): the values that are not numbers,
each quoted with its count, then the jload() call as typed with `na =`
naming them, which reads them as missing and the variables as numbers.
It replaces the load scan's block for these variables, whose declaration
left the variable text.

## Usage

``` r
.jst_marker_note(marks, vars, line, obj_name = NULL, labels = NULL)
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

- obj_name:

  The data frame's name, for the base R lines.

- labels:

  The variables' labels, parallel to `marks`, NA where there is none;
  NULL for none.

## Value

Character(1).

## Details

Since Session 381 (Fix Slate 24, the (S380) item): a sheet's variable
that also holds a number stored as text (`stored` above zero, from
[`.jst_marker_columns()`](https://jma61.github.io/jstats/reference/dot-jst_marker_columns.md))
stays text after a reload with `na =`, so its lines are base R's instead
([`.jst_numeric_lines()`](https://jma61.github.io/jstats/reference/dot-jst_numeric_lines.md)):
its cells made missing, then
[`as.numeric()`](https://rdrr.io/r/base/numeric.html), then its label
put back if jload() gave it one. Beside a variable the reload does
serve, the reload comes first – its `na =` names every value in the
note, so the stored variable's cells are already missing – and the
stored variable gets only the
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) line.
