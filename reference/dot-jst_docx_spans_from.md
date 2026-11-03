# Internal helper: does a row's cell at a column span columns?

A fit row's cell spans its model's columns (Session 403); the row's span
field holds each span as c(from, to).

## Usage

``` r
.jst_docx_spans_from(r, j)
```

## Arguments

- r:

  A row of a jst_table.

- j:

  A column index.

## Value

Logical.
