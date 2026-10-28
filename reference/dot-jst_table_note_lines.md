# Internal helper: the note lines of a table, as marked-up text

One string per line: the general note (the style's label, then the
sentences), the specific notes (each mark and its text), the probability
note. The light markup the Word writer reads – *italic* and
^superscript^ – is kept, or stripped for the console.

## Usage

``` r
.jst_table_note_lines(tbl, style, plain = FALSE)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- plain:

  Logical; TRUE strips the markup for the console, where a mark is
  written ^a.

## Value

Character vector, possibly empty.
