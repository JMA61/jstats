# Internal helper: the note paragraphs of a table

Internal helper: the note paragraphs of a table

## Usage

``` r
.jst_docx_note_pars(tbl, style, keep_next = FALSE, size = NULL)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- keep_next:

  Logical; for a note inside a row.

- size:

  Points, or NULL for the style's note.size (a table fitted to the page
  steps it down with the table's size, Session 403).

## Value

Character; one paragraph per note line.
