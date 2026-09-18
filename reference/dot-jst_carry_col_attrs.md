# Internal helper: carry passenger attributes through a column rebuild

A haven-imported column carries attributes beyond its labels and its
missing-value declaration: the platform display format (`format.spss`
such as "F2.0" or "A20", `format.stata` such as "%9.0g"), the SPSS Data
Editor column width (`display_width`), and whatever a future haven
attaches. R never reads them; haven's writers do, and a writer that
finds none invents a default (F8.2 for a .sav numeric), so a rebuild
that drops them changes how the column displays when the file goes back
to its platform (S298 field finding 2: 52 declared columns read back
F8.2 in place of their delivered format).

## Usage

``` r
.jst_carry_col_attrs(from, to)
```

## Arguments

- from:

  The column before the rebuild.

- to:

  The rebuilt column.

## Value

`to`, with the passenger attributes of `from` added.

## Details

Rebuilding through
[`haven::labelled()`](https://haven.tidyverse.org/reference/labelled.html),
[`haven::labelled_spss()`](https://haven.tidyverse.org/reference/labelled_spss.html),
or `labelled::val_labels<-` (which rebuilds internally) keeps only what
the constructor is told. This helper copies onto `to` every attribute of
`from` that the rebuild does not own – everything except the structural
set (`class`, `levels`, `names`, `dim`, `dimnames`) and the owned set
(`label`, `labels`, `na_values`, `na_range`) – and fills only attributes
`to` lacks, so it restores what was dropped and never overrides what the
rebuild set. A plain vector with no attributes passes through unchanged.

Called at the exit of every column rebuild that keeps the column's
storage kind: jrelabel(), jrecode(), the three jdeclare_missing() branch
builders, jconvert()'s write-backs, and jsave's .dta pre-write.
jencode() does NOT call it by design: its source is text and its result
numeric, so the source's "A" format would be wrong on the result (S299).
