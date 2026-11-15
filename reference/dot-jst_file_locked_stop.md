# Internal helper: the stop for a file that cannot be written

One sentence for every function that replaces a file (Session 430, the
(S429) open-file item): jtable() and jstyle() before their overwrite
question and at the write, jsave() the same. The program named is the
one that opens the file's kind – Word for a .docx, Excel for a .xlsx or
a .csv, SPSS for a .sav, Stata for a .dta – and "another program" for
any other; the sentence is jtable()'s since Session 400, which Jeff read
as good ("The first part - the actual error message, looks good.").

## Usage

``` r
.jst_file_locked_stop(path, fn)
```

## Arguments

- path:

  The file's path.

- fn:

  The user-facing function's name.

## Value

Does not return; stops.
