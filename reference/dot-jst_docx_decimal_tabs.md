# Internal helper: the decimal tab position of each number column

Measured from the cell's left text edge: the cell's inner width less the
widest tail (the point and the digits after it, and any stars), so the
numbers' points line up near the right edge.

## Usage

``` r
.jst_docx_decimal_tabs(tbl, widths, size, margin)
```

## Arguments

- tbl:

  A jst_table.

- widths:

  The column widths.

- size:

  Points.

- margin:

  The cell margin.

## Value

Integer vector; NA for the stub.
