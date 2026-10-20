# Internal: a sheet's variables of numbers made text by a few cells

The Excel side of ruling R31's question 5: each text variable not named
in `text =`, its footnote rows left out of the first variable. A
variable is named only when its numbers are NUMBER cells and every text
cell holds a value that is not a number: readxl gives a variable holding
a text cell as text, and a number stored as text keeps it text whatever
`na =` names, so the line the note offers would not make it numbers (ICD
codes typed as text, 250.10 beside 250.1, are text cells throughout).
Only the cells say which (as
[`.jst_excel_cells_numeric()`](https://jma61.github.io/jstats/reference/dot-jst_excel_cells_numeric.md)
does for footnotes, Session 365), read again for the variables in
question.

## Usage

``` r
.jst_marker_columns(df, skip_pos = integer(0), cells = NULL, header = TRUE)
```

## Arguments

- df:

  The sheet as read.

- skip_pos:

  Positions not to look at (`text =`).

- cells:

  A function of positions giving those variables read as cells (readxl's
  `col_types = "list"`), or NULL for no such check.

- header:

  jload()'s `header`: read with FALSE, a variable whose first cell is a
  word is passed over, since that row may be the names.

## Value

A list of list(pos, values, counts).
