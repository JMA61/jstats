# Internal helper: the table of a jst_table, as XML

Internal helper: the table of a jst_table, as XML

## Usage

``` r
.jst_docx_table(tbl, style, number, widths, size = NULL, note_size = NULL)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- number:

  The table's number (for a caption row).

- widths:

  Column widths in dxa.

- size, note_size:

  Points, or NULL for the style's size and note.size: a table fitted to
  the page passes the stepped-down sizes (Session 403).

## Value

Character(1); the w:tbl element.
