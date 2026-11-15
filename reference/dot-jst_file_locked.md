# Internal helper: is a file held open by another program?

Session 430 (the (S429) open-file item; Jeff, of a Word file open in
Word: "I think that doing this will be common among users, so we should
get the error message down well"). On Windows a program that has a file
open – Word a .docx, Excel a .xlsx or a .csv, SPSS a .sav – holds it
against being replaced, and R found that out only at the write, after
the overwrite question had been asked and answered, in R's own warnings
("Access is denied", "Permission denied"). The file is tried for
writing, opened and closed again with nothing written, so a file that
cannot be replaced is said before the question. Elsewhere a program does
not hold a file so, and the answer is FALSE without a try. A file that
does not exist is not held.

## Usage

``` r
.jst_file_locked(path)
```

## Arguments

- path:

  The file's path.

## Value

TRUE or FALSE.
