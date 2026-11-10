# Internal helper: the note lines of a table, as marked-up text

One string per line: the general note (the style's label, then the
sentences), the specific notes (each mark and its text), the probability
note, in the order note.order gives – apa APA's, report the report
manuals' (the probability note and the specific notes, then the general
note; ruling R79, Session 413). Under note.sentences = lines each
sentence of the general note, and each specific note, is a line of its
own (ruling R75: report's value, Jeff's practice); under paragraph the
general note is one paragraph and the specific notes another, as APA
sets them. A call's source = is the general note's last sentence under
source.position = note (APA puts a source in the general note), or under
line a line of its own, last, after source.label. The light markup the
Word writer reads – *italic* and ^superscript^ – is kept, or stripped
for the console.

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
