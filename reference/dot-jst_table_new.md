# Internal helper: a table structure

The neutral form every writer renders (the reference, Part 2.1).

## Usage

``` r
.jst_table_new(
  type,
  columns,
  rows,
  caption,
  notes,
  spanners = NULL,
  style = "apa"
)
```

## Arguments

- type:

  Character(1); the table type, the style section's name.

- columns:

  A data frame, one row per column: key, label, kind ("text" or
  "number"), italic (logical). The first column is the stub.

- rows:

  A list; each row a list with kind ("data" or "heading"), label, indent
  (0 or 1), marks (character; the specific-note marks the label
  carries), cells (a named list of formatted strings, by column key; a
  heading has none) and raw (the numbers the cells were made from).

- caption:

  A list: number (NA until a document assigns one) and title.

- notes:

  A list: general (character; one string per sentence), specific (a list
  of mark/text pairs) and probability (character).

- spanners:

  A list of heading spanners (label, from, to: column positions), or
  NULL.

- style:

  The style name the table was built under.

## Value

An object of class "jst_table".
