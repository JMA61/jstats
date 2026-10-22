# Internal: the note for a text variable's missing cells that a format writes as blank text

Ruling R13 (Jeff, S345; built Session 351). SPSS format (.sav), Stata
format (.dta), SAS interchange format (.xpt) and CSV format (.csv) have
no missing value for text: haven and write.csv() write a text variable's
NA as an empty string, and jload() reads that back as the `<blank>`
category, counted as valid (the S340 decision: a blank is reported,
never assumed missing, and a file cannot say which blanks were once
missing). So jsave() says so when it happens: the variables, the cells,
and the format that keeps them (.rds). The .xpt format and a factor in a
CSV file (written as its labels) lose the same way, probed at S351 and
added on Jeff's lean. A missing NUMBER survives every format. A loss
note, as the label and declaration losses are: not gated to the
joutput() levels.

Since Session 389 (ruling R34) Excel format (.xlsx) is one of them: it
writes a text NA as an empty cell, as it writes a blank, and jload() now
reads a sheet's blank text cells as `<blank>`, as a CSV file's, so the
cell comes back counted as valid. A factor's NA goes the same way
(written as its labels, as in a CSV file). R format (.rds) alone keeps
them missing.

## Usage

``` r
.jst_jsave_text_na_note(data, ext)
```

## Arguments

- data:

  The data frame as written.

- ext:

  Lowercase target extension.

## Value

The note, or NULL when the format keeps text NA or the frame has none.
