# Internal helper: the headings and the specific-note marks of a table

One home for headings = and markers = in every table type. headings =
partitions the variables – every variable under one heading, in the
headings' order, a name given twice or not in the results refused, a
variable left out refused – and replaces the headings a named list of
results gives. markers = assigns each specific note a mark in the
style's glyphs, in the order given; a variable may carry several marks,
one per note.

## Usage

``` r
.jst_table_roles(vars, heading, headings, markers, marks)
```

## Arguments

- vars:

  Character; the variables, in the results' order.

- heading:

  Character, one per variable; the heading a named list of results gives
  it, or NA.

- headings, markers:

  The named lists jtable() read, or NULL.

- marks:

  The style's marks key ("letters" or "symbols").

## Value

A list: order (integer; the variables' new order), heading (character;
each variable's heading in that order), marks (a named list, by
variable: the marks its label carries) and specific (a list of mark/text
pairs).
