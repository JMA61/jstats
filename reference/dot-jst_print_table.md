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
  header.indent = 0
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

  Optional character vector of alignment codes ("l", "r", "c", or "d"),
  one per displayed column. If NULL, auto-detects: numeric = right,
  character/other = left. Code "d" is a decimal-tab: data cells are
  right-justified (so a uniform decimal-places column aligns on the
  decimal point) while the header stays centered over the column.

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
