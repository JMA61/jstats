# Internal helper: the decimal tab position of each number column

Measured from the cell's left text edge: the block of numbers – the
widest whole part and the widest tail (the point and the digits after
it, and any stars) – centered in the cell's inner width, never past the
inner width less the widest tail (Session 401; until then every block
sat at that right-hand limit), and never left of the widest whole part
(Session 405).

## Usage

``` r
.jst_docx_decimal_tabs(tbl, widths, size, margin, font = NULL)
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

- font:

  Character(1), or NULL: the face measured in (Session 407).

## Value

Integer vector; NA for the stub.
