# Internal helper: a table's columns widened to a width, in proportion

Each column's share of the extra width follows its own width; what the
rounding leaves goes to the stub.

## Usage

``` r
.jst_docx_widen(w, to)
```

## Arguments

- w:

  Integer, the column widths.

- to:

  The width wanted, dxa; never narrower than `sum(w)`.

## Value

Integer.
