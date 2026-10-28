# Internal generic: build a table structure from a saved result

One method per result class. A class with no method stops in jtable()'s
words: the table types come one build at a time.

## Usage

``` r
.jst_table_build(
  x,
  style,
  headings = NULL,
  markers = NULL,
  title = NULL,
  note = NULL,
  ...
)
```

## Arguments

- x:

  The saved result.

- style:

  The style list.

- headings:

  A named list: each heading's variables (or NULL).

- markers:

  A named list: each specific note's variables (or NULL).

- title:

  The user's title, or NULL for the type's template.

- note:

  The user's general note, or NULL.

- ...:

  Unused.
