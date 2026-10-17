# Internal: the line of a CSV file each case starts on

count.fields() gives each line's number of values: NA for a line whose
quoted value carries on to the next, the count on the line a case ends
on, and 0 for an empty line, which read.csv() skips between cases. A
case starts on the first line after the last case ended that is not
empty (Session 365, for the stray-parts note).

## Usage

``` r
.jst_csv_case_lines(path, skip, enc, header)
```

## Arguments

- path, skip, enc:

  As jload() read the file.

- header:

  TRUE when the first case is the names line.

## Value

Integer vector: the line of the file each case starts on; NULL when the
lines cannot be counted.
