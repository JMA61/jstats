# Internal helper: the style a built table is drawn in

A table keeps the style it was built under, the call's own settings
included, so it prints and writes as it was built; a table made before
Session 401 carries the style's name instead, read again here.

## Usage

``` r
.jst_table_style(tbl, style)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style to use when the table carries none.
