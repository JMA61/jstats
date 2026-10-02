# Internal helper: print a formatted table with precise column alignment

Purpose-built table printer that replaces knitr::kable() for console
output. Provides right-justified numbers, left-justified text, clean
separator lines, and consistent indentation. No external dependencies —
pure base R.

## Usage

``` r
.jst_print_table(
  df,
  col.names = NULL,
  row.names = TRUE,
  align = NULL,
  caption = NULL,
  indent = 0,
  header.indent = 0,
  trim = FALSE,
  digits = NULL
)
```

## Arguments

- df:

  A data frame to print.

- col.names:

  Optional character vector of column headers. If NULL, uses
  `names(df)`.

- row.names:

  Logical. If TRUE, includes row names as the first column.

- align:

  Optional character vector of alignment codes ("l", "r", "c", "d",
  "ln", or "bc"), one per displayed column. If NULL, auto-detects:
  numeric = right, character/other = left. Code "d" is a decimal-tab:
  data cells are right-justified (so a uniform decimal-places column
  aligns on the decimal point) while the header stays centered over the
  column. Code "ln" is left, no-trim (a caller-supplied leading space
  survives). Code "bc" is block-centered: each value is right-justified
  in a block the width of the column's widest value, and that block is
  centered under the header, so counts align on their ones digit down
  the column while the column reads centered rather than right-heavy
  (the Case Processing bottom table's Session 52 rule, available to any
  table since Session 313). The header is centered over the column, as
  for "d".

- caption:

  Optional title string printed above the table.

- indent:

  Number of leading spaces for each data row. Default 0, so data rows
  sit flush at column 1, aligned with the caption, header, and separator
  (which use `header.indent`). Callers that want a nested/indented
  sub-table pass a positive value (e.g. `indent = 4`).

- header.indent:

  Number of leading spaces for the caption, header row, and separator
  row. Defaults to 0. With the default `indent`, header and data share
  the same left edge; raise one relative to the other only for special
  layouts.

- trim:

  Logical. When TRUE, trailing spaces are removed from the header row
  and every data row before printing. A centered header or a
  left-aligned or block-centered cell in the LAST column is padded to
  the column's width, so without the trim those lines end in spaces –
  invisible on screen but carried into anything copied or captured.
  Default FALSE. jdesc's two tables pass TRUE (Session 316), and since
  Session 327 so do the statistics tables of jt, jaov and jalpha,
  jlogistic's Omnibus, Model Summary and Classification tables, both VIF
  tables and jscreen's Variable Types, each with its numeric columns
  block-centered ("bc"). Making the two the default for every table is a
  separate, package-wide decision.

- digits:

  Optional named vector that fixes the decimal places of numeric
  columns, keyed by the data frame's own column names (not the display
  headers), e.g. `c(Mean = 3, SD = 3)`. A named column prints every
  value to exactly that many places, trailing zeros kept (0.100,
  16.000), through
  [`.jst_make_fmt()`](https://jma61.github.io/jstats/reference/dot-jst_make_fmt.md),
  so a value that rounds to zero from below prints unsigned and NA stays
  a blank cell. A numeric column the vector does not name keeps the
  detected decimals described in the body, so a caller that passes
  nothing prints exactly as before; an NA entry also keeps the
  detection, and an entry naming a non-numeric column is ignored. A name
  that matches no column is an error, so a misspelled name cannot fall
  back to the detection unnoticed. NULL (the default) fixes no column.
  Added Session 326: a column's decimal places come from what it holds –
  a statistic at the digits setting, a fixed convention at its own –
  never from the values that happen to be in it.
