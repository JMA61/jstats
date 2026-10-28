# Make a publication table from a saved result

`jtable()` turns a saved analysis result into a publication table: it
prints a preview in the console and, when `file` is given, writes the
table to a Word file (.docx) that opens in Word, LibreOffice and Google
Docs. The table's look and conventions come from a style (the built-in
`"apa"` style in this version); the preview is a facsimile of the Word
table, so what prints is what the file holds.

## Usage

``` r
jtable(
  x,
  headings = NULL,
  markers = NULL,
  title = NULL,
  note = NULL,
  file = NULL,
  style = "apa",
  overwrite = FALSE,
  print = NULL,
  ...
)

# S3 method for class 'jst_table'
print(x, ...)
```

## Arguments

- x:

  A saved result – what an analysis function returns, kept with `<-` –
  or a list of them. A list of
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md) results
  stacks into one table, each result's variables under its name in the
  list when the list is named. A table `jtable()` has already built, or
  a list of them, goes to the file as it is, the tables in the order
  given and numbered so.

- headings:

  A named list: each heading and the variables under it, bare or in
  quotes, e.g.
  `list("Dependent variable" = Wellbeing, "Independent variables" = c(Income, Age))`.
  Every variable of the result goes under one heading; the table follows
  the list's order.

- markers:

  A named list: each specific note's text and the variables it marks,
  e.g. `list("Mean-centered" = c(Income, Age))`. The style assigns the
  marks (superscript letters under APA), sets each on its rows' labels,
  and writes the note under the table.

- title:

  The table's title; the style's template title when NULL.

- note:

  The general note's text, after the N the style writes; `*text*` sets a
  word in italics. NULL for none.

- file:

  The Word file to write, with its .docx extension: a bare name goes in
  the output folder (`joptions(output.dir = )`) or the working
  directory; a path with a folder goes there. NULL writes nothing.

- style:

  The style's name; `"apa"` in this version.

- overwrite:

  Logical. Replace a file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

- print:

  Print the preview? NULL (the default) follows the
  [`joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  level: the preview prints unless the level is `"silent"`. TRUE prints
  it under any level; FALSE prints nothing and writes the file alone.

- ...:

  Not used. An input `jtable()` does not take stops with "unused input".

## Value

The table, invisibly: an object of class `jst_table`, which prints its
preview when typed.

## Details

This version makes one table type: a descriptives table from one or more
[`jdesc`](https://jma61.github.io/jstats/reference/jdesc.md) results,
the variables under role headings when `headings` names them, each
specific note's variables marked when `markers` names them. Further
table types follow.
