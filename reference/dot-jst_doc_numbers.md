# Internal helper: each item's number in a document

Tables and figures are numbered on sequences of their own (ruling R63):
Table 1, Figure 1, Table 2 in a document that holds them in that order.

## Usage

``` r
.jst_doc_numbers(items)
```

## Arguments

- items:

  A list of jst_table and jst_figure.

## Value

Integer, one per item.
