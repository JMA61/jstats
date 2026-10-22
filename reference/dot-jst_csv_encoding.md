# Internal: the encoding a CSV file is read in

R reads a CSV file as UTF-8. One saved by Excel on Windows as "CSV
(Comma delimited)" is in that computer's own encoding – Windows-1252 on
a Western European or English one – and a single accented letter or
curly apostrophe in it stopped jload() on R's "invalid multibyte string"
(the import audit, Session 362). A file whose bytes are valid UTF-8 (a
mark at the start included) is read as R reads it; any other is read as
Windows-1252, or, when even that cannot read it, as Latin-1, which reads
every byte. A Chinese, Japanese or Korean Windows saves in its own
encoding, which is not tried first (Session 390, ruling R35): on such a
computer a Western file, which reads right as Windows-1252, would then
read wrongly, and without a word. jload()'s note says to save the file
from Excel as "CSV UTF-8" instead.

## Usage

``` r
.jst_csv_encoding(path)
```

## Arguments

- path:

  The file.

## Value

NULL for UTF-8, else "CP1252" or "latin1".
