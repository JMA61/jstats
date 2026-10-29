# Internal helper: the decimal tab position of each number column

Measured from the cell's left text edge: the block of numbers – the
widest whole part and the widest tail (the point and the digits after
it, and any stars) – centered in the cell's inner width, and never past
the inner width less the widest tail (Session 401; until then every
block sat at that right-hand limit).

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
