# Internal helper: put a document's tables in its place in a list

And a set of charts – what jplot() returns for a result it draws several
plots of – its charts, each a figure of its own (Session 415).

## Usage

``` r
.jst_tables_splice(results)
```

## Arguments

- results:

  The list jtable() was given.

## Value

The list, each jst_tables element replaced by its tables and figures,
and each set of charts by its charts, names kept for the other elements.
