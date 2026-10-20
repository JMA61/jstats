# Internal: a sheet's variables of numbers made text by a few cells

The Excel side of ruling R31's question 5: each text variable not named
in `text =`, its footnote rows left out of the first variable. A
variable is named only when NUMBER cells are more than half of its cells
that are not empty, and at least one text cell holds a value that is not
a number (ICD codes typed as text, 250.10 beside 250.1, are text cells
throughout, and are never named). readxl gives a variable holding a text
cell as text, so a number stored as text beside the number cells keeps
it text whatever `na =` names; since Session 381 (Fix Slate 24, the
(S380) item) such a variable is named too, with `stored` counting those
cells, and the note gives it the lines that make it numbers in R rather
than a reload (until then it was passed over, and the scan's declaration
left it text). A stored number whose value numbers would change – a
leading zero, more than 15 digits (ruling R31, questions 1 and 2) –
still passes the variable over. Only the cells say which (as
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

A list of list(pos, values, counts), each with `stored`, the count of
numbers stored as text, when `cells` is given.
