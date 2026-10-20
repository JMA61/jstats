# Internal: a CSV file's variable names, from its names line alone

For jload()'s `text =` (Session 380): the names read.csv() gives the
variables, read before the file is, so a name the file does not have
stops ahead of the overwrite question and the read. With
`header = FALSE` they are V1 to Vk, k the count of values most lines
hold.

## Usage

``` r
.jst_csv_header_names(path, skip, enc, header, n_cols)
```

## Arguments

- path, skip, enc:

  As jload() reads the file.

- header:

  jload()'s `header`.

- n_cols:

  The count of values most lines hold, or NULL.

## Value

Character vector, or NULL when the line cannot be read.
