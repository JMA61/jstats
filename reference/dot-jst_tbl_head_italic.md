# Internal helper: which of a table's column heads are set in italics

APA sets a statistic's SYMBOL in italics (n, M, SD) and a word upright.
A head is italic when its column is a statistic's
(`.jst_tbl_italic_heads`) and its label is still the symbol the built-in
apa style gives it: a word a style puts in its place – "Mean", "Std
Dev." – is set upright (Session 401, on the journal file's walk).

## Usage

``` r
.jst_tbl_head_italic(type, keys, labels)
```

## Arguments

- type:

  The table type.

- keys:

  The columns' keys, the stub's first.

- labels:

  Their labels.

## Value

Logical, one per column.
