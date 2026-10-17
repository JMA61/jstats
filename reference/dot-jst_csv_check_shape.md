# Internal: the shape of a CSV file, checked before it is read

read.csv() decides how many variables a file has from its first line and
its first five lines, and two shapes go wrong without a word (the import
audit, Session 362): a first line with FEWER fields than the lines below
it – a title above the names, a missing name, a semicolon file from
European Excel – makes the first values of every line row names, which
jload() then drops, or stops on R's "more columns than column names";
and a line further down with MORE fields than the first is split into
two cases. Every line's fields are counted first (count.fields(),
quoting as read.csv() quotes), and those shapes stop here, saying what
the file holds and what to do. A line with fewer fields than the first
is read as it always was, its last cells empty.

## Usage

``` r
.jst_csv_check_shape(path, skip, enc, shown, line_for, obj_name, header = TRUE)
```

## Arguments

- path:

  The file.

- skip:

  Lines skipped above the names.

- enc:

  NULL, or the encoding the file is read in.

- shown:

  The file's name for the prose.

- line_for:

  jload()'s line builder: `line_for(skip = 2)` gives the jload() call
  that reads the file with skip = 2.

- obj_name:

  The data frame's name, for the read.csv2() line.

- header:

  As jload() reads the file.

## Value

Invisibly: with header = FALSE the number of values most lines hold
(NULL when the lines could not be counted); otherwise NULL. Or stops.

## Details

Read with header = FALSE (ruling R21, Session 365) a file has no names
line to measure the others against: every line is a case, measured
against the count most lines hold. A line holding more stops, as a line
longer than the names line does; a shorter one is read with its last
cells empty; the title search, which looks for a names line, is not
made. The count is returned, and jload() reads that many variables
(col.names), so a long line past the first five – the lines read.csv()
counts – could not be split even if one got through.
