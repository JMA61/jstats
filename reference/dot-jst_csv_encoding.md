# Internal: the encoding a CSV file is read in

R reads a CSV file as UTF-8. One saved by Excel on Windows as "CSV
(Comma delimited)" is in Windows-1252, and a single accented letter or
curly apostrophe in it stopped jload() on R's "invalid multibyte string"
(the import audit, Session 362). A file whose bytes are valid UTF-8 (a
mark at the start included) is read as R reads it; any other is read as
Windows-1252, or, when even that cannot read it, as Latin-1, which reads
every byte.

## Usage

``` r
.jst_csv_encoding(path)
```

## Arguments

- path:

  The file.

## Value

NULL for UTF-8, else "CP1252" or "latin1".
