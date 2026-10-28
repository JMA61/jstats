# Internal helper: the column widths of a table, in dxa

From the widest text each column holds at the style's size, plus the
cell margins; the stub from its labels and their indents.

## Usage

``` r
.jst_docx_widths(tbl, style)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

## Value

Integer vector, one per column.
