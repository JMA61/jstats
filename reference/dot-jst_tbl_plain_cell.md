# Internal helper: is a cell set centered rather than on its decimal tab?

A cell of a text column (an ANOVA's df, "3, 99") or a cell with no digit
(a correlation's em dash): both Word and LibreOffice need a number on a
decimal tab, and LibreOffice sets other text from the tab rightward
(Session 405).

## Usage

``` r
.jst_tbl_plain_cell(s, kind = "number")
```

## Arguments

- s:

  Character; the cells.

- kind:

  The column's kind ("number" or "text").

## Value

Logical, one per cell.
