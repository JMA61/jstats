# Internal: a title row above an Excel sheet's names

Ruling R9 part (2): a sheet whose first row is a title loads the title
as a variable name, the real names as a case and every column as text,
and readxl said only "New names:". When at most half the columns of the
first row read have a name, the first twenty rows are read again as they
stand (range =, which keeps empty rows, so the row numbers are the
sheet's) and, when a later row holds words in at least half the columns
and in every cell it fills, it is offered as the names: the row, and the
skip = call that reads from it. A note, not a stop: one unnamed column
is common and legitimate, and nothing is offered then.

## Usage

``` r
.jst_excel_title_row(path, sheet, skip, nm)
```

## Arguments

- path, sheet, skip:

  As jload() reads the sheet.

- nm:

  The names read.

## Value

NULL, or list(title, names): the sheet rows of the title and of the
names.
