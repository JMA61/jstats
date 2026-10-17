# Internal: jload()'s note on rows and columns that may not be data

Session 365 (the S362 audit's item 17). One sentence for each kind found
(Rule E): the empty rows, the footnotes (and the variable they made
text), the empty columns, the row numbers; each by its place in the file
(an Excel row or column letter, a CSV line or column number) with the
case numbers or the variable names in parentheses, or, when the place
cannot be counted, by the cases and variables alone. Then that they were
read as data and nothing was removed, and the way to leave them out.

## Usage

``` r
.jst_stray_parts_note(
  parts,
  vars,
  shown,
  sheet_file,
  case_pos,
  col_pos,
  header,
  data_name
)
```

## Arguments

- parts:

  From .jst_import_stray_parts(), text_col settled.

- vars:

  The variables' names, as loaded.

- shown:

  The file's name.

- sheet_file:

  TRUE for an Excel file, FALSE for CSV.

- case_pos:

  NULL, or each case's row or line in the file.

- col_pos:

  NULL, or each variable's column in the file.

- header:

  As jload() read the file.

- data_name:

  The data frame's name, for the fallback.

## Value

Character(1), or NULL when nothing was found.
