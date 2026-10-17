# Internal: where an Excel sheet's data begin

readxl starts at the first row after skip = that holds anything and at
the leftmost column that does, so a case's row and a variable's column
in the sheet are counted from there (Session 365, for the stray-parts
note). The first 200 rows after skip = are read as cells (col_types =
"list", as .jst_excel_title_row() reads them); the columns left of the
one they start in are then read down the whole sheet, since one cell
there moves readxl's start.

## Usage

``` r
.jst_excel_origin(path, sheet, skip)
```

## Arguments

- path, sheet, skip:

  As jload() read the sheet.

## Value

list(row, col): the sheet row and column of the first cell readxl read;
NULL when it cannot be found.
