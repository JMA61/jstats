# Internal: does a CSV file have exactly one column?

Reads the header line alone – the separator and quoting read.csv() uses,
so a quoted name holding a comma is one field – and counts its fields.
jload() reads a one-column file without skipping empty lines (Session
351), since there an empty line is a case with an empty cell. A file
that cannot be read this way answers FALSE, leaving read.csv()'s default
and its own error.

## Usage

``` r
.jst_csv_one_column(path)
```

## Arguments

- path:

  Path to the file.

## Value

TRUE or FALSE.
