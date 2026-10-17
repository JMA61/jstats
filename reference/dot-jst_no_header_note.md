# Internal: jload()'s note on names that are all numbers

Session 365 (the S362 audit's item 14; ruling R21): the names read from
the file are all numbers, so the line or row they came from may be the
first case. The names as read, then the jload() call with header =
FALSE, which reads that line as a case.

## Usage

``` r
.jst_no_header_note(shown, nm, sheet_file, line)
```

## Arguments

- shown:

  The file's name.

- nm:

  The names as read.

- sheet_file:

  TRUE for an Excel file ("row"), FALSE for CSV ("line").

- line:

  The jload() call with header = FALSE.

## Value

Character(1).
