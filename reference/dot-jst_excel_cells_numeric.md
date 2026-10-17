# Internal: are some cells of an Excel column numbers?

A column holding numbers and one text cell is read as text, and readxl
gives its numbers back as their digits; so are numbers stored as text in
Excel. Only the cells say which (Session 365: the stray-parts note says
the footnotes made a variable text only when its other cells are
numbers).

## Usage

``` r
.jst_excel_cells_numeric(path, sheet, rows, col)
```

## Arguments

- path, sheet:

  As jload() read the sheet.

- rows, col:

  The sheet rows and the column.

## Value

TRUE when every one is a number cell.
