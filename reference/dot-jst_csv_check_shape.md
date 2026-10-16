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
.jst_csv_check_shape(path, skip, enc, shown, line_for, obj_name)
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

  A function of one argument string ("skip = 2"): the jload() call that
  reads the file with it.

- obj_name:

  The data frame's name, for the read.csv2() line.

## Value

Invisibly NULL, or stops.
