# Internal: a sheet's blank text cells, read as a CSV file's are

Ruling R34 (Jeff, Session 389: "Let's go with your recommendation on the
excel issue."). readxl reads every blank cell of a sheet as missing – an
empty cell, a cell holding an empty string, and a cell holding only
spaces, whose spaces its XML parser drops before readxl sees them, under
every option (`trim_ws = FALSE`, `na = character(0)`) – so a text
variable's blank cells loaded as missing, where the same cells in a CSV
file are the `<blank>` category, counted as valid (Cross-cutting 7 (3):
a blank is reported, never assumed missing; the (S362) item). They
become empty strings here, so a sheet's text variable reads as a CSV
file's does
([`.jst_csv_type_columns()`](https://jma61.github.io/jstats/reference/dot-jst_csv_type_columns.md)):

- a variable of words gets `""` in its blank cells, and so does one
  whose values are T and F standing alone, kept as written;

- a variable whose values are all numbers, or the words TRUE and FALSE,
  stored as text keeps them missing, as a CSV file's variable of numbers
  does, a variable kept as text for a leading zero or a long number
  among them, and so does one the note on a few cells names;

- a `text =` variable gets `""`, being read as written.

Cells `na =` names stay missing: with `na =` given, the variables are
read again with `na = ""` alone, and only the cells missing in that read
are blank; `na = ""` itself keeps every blank cell missing. The spaces
cannot be recovered, so a cell of spaces becomes an empty string, the
one `<blank>` category either way. An Excel error cell (#N/A), which
readxl also reads as missing, becomes `<blank>` in a variable of words
with them (a CSV file holds it as the word \#N/A, also valid).

## Usage

``` r
.jst_sheet_blank_text(df, text_pos, marker_pos, na, reread)
```

## Arguments

- df:

  The sheet as read.

- text_pos:

  Positions named in `text =`.

- marker_pos:

  Positions the note on a few cells names
  ([`.jst_marker_columns()`](https://jma61.github.io/jstats/reference/dot-jst_marker_columns.md)).

- na:

  jload()'s `na =`, or NULL.

- reread:

  A function of positions giving those variables read again as text with
  `na = ""` alone.

## Value

`df`, its blank text cells empty strings.
