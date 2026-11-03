# Internal helper: the column widths of a table, in dxa

From the widest text each column holds at the style's size, plus the
cell margins; a column of numbers at least as wide as its block, the
widest whole part beside the widest tail (Session 405); the stub from
its labels and their indents; a spanner's label spread over its columns
when it is wider than they are.

## Usage

``` r
.jst_docx_widths(tbl, style, size = NULL, pad = 120L)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- size:

  Points, or NULL for the style's size.

- pad:

  The twips added to each number column beside its margins (120; a table
  fitted to the page gives up half of it first, Session 403).

## Value

Integer vector, one per column.
