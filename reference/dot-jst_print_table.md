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
  trim = TRUE,
  digits = NULL,
  gap = 2L
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
  "ln", "bc", or "bd"), one per displayed column. If NULL, auto-detects:
  numeric = right, character/other = left – the form a listing of data
  rows wants, and jcomplete()'s preview is the one caller that passes
  none. Every statistics table names its columns, because only the
  caller knows that a text column holds p-values or labels (a default
  keyed to the column's type would leave every p header flush left;
  Session 328). Code "d" is a decimal-tab: data cells are
  right-justified (so a uniform decimal-places column aligns on the
  decimal point) while the header stays centered over the column. Code
  "ln" is left, no-trim (a caller-supplied leading space survives). Code
  "bc" is block-centered: each value is right-justified in a block the
  width of the column's widest value, and that block is centered under
  the header, so counts align on their ones digit down the column while
  the column reads centered rather than right-heavy (the Case Processing
  bottom table's Session 52 rule, available to any table since Session
  313). The header is centered over the column, as for "d". Code "bd" is
  block-centered on the decimal point (Session 328): each cell is split
  where its whole-number part ends, the whole-number parts are
  right-justified and what follows them (a decimal fraction, a percent
  sign, a significance marker) is left-justified, so the cells of a
  column line up on the decimal point whatever each one carries – a
  count over an expected count over a percentage in jcrosstab's cells, a
  whole number over a one-decimal value in jdesc's Min and Max. The two
  widths together are the block, centered under the header as a "bc"
  block is. A cell that does not start with a number sits with the
  whole-number parts. Where a header or a block cannot be centered
  exactly, the odd space goes on the LEFT, so the text sits one place
  right of center: a one-digit df under "df" reads as right-justified,
  where a number conventionally sits. One rule for every table, the Case
  Processing block included (Session 328); the odd space went on the
  right through Session 327.

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

  Logical. When TRUE (the default since Session 328), trailing spaces
  are removed from the header row and every data row before printing. A
  centered header or a left-aligned or block-centered cell in the LAST
  column is padded to the column's width, so without the trim those
  lines end in spaces – invisible on screen but carried into anything
  copied or captured. It was opt-in from Session 316 (jdesc's two
  tables) through Session 327 (the statistics tables); no table wants
  the padding, so no caller passes FALSE.

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

- gap:

  The number of spaces between columns: one whole number, used as given
  (the default, 2, is the gap every table has had), or several in order
  of preference. Given several, the table takes the first gap at which
  its full width – the indent, the columns and the gaps between them –
  still fits the message width
  ([`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)'s
  `message.width`, 76 by default), and the last one when none fits.
  jcrosstab's crosstab passes `c(4, 2)`: its cell columns are narrow and
  crowd at two spaces, so a table with room takes four and a wide one
  keeps two (Session 329, Jeff). The width is the table's own; a caption
  longer than the table does not count. The message width is the ceiling
  because it is the one width the package already keeps, and it gives
  the same table on every screen where the console's width changes with
  the pane.
