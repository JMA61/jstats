# Internal: rows and columns of a file that may not be data

Session 365 (the S362 audit's item 17): an Excel sheet's blank rows,
blank columns and footnote lines, and their CSV kin – a line of commas,
a trailing comma's column, the row numbers write.csv() writes – loaded
as cases and variables, and nothing said so. Found here on the data as
read and the names as the file has them; nothing is dropped. A cell is
empty when it is NA, or text of nothing but spaces.

- rows:

  cases with nothing in them, in data of two or more variables (in a
  one-column file an empty line is a case with a missing value, Session
  351); with row numbers, the other variables

- notes:

  the last cases, below the data, with text that is not a number in the
  first variable and nothing in the others

- cols:

  variables with no name and nothing in them (with header = FALSE,
  nothing in them)

- rownum:

  1 when the first variable has no name and holds 1 to n in order, n of
  2 or more, as write.csv()'s row names do

- rest:

  the other cases with something in the first variable

- text_col:

  TRUE when every one of those reads as a number, so the notes are why
  the first variable is text

## Usage

``` r
.jst_import_stray_parts(df, nm, header = TRUE)
```

## Arguments

- df:

  The data frame as read.

- nm:

  The names as the file has them.

- header:

  As jload() read the file.

## Value

list(rows, notes, cols, rownum, rest, text_col, n), n the number of
cases.
