# Internal helper: a table's own font and size, on its runs

Word takes a run's font from the document's defaults unless the run
names one. A table whose style's font differs from the document's gets
it on every run – w:rFonts first in the run's properties, as Word's
schema orders them, with East Asian text set in it as the defaults set
it – and on every paragraph mark; a table whose size differs gets it on
the paragraph marks that carry none (its runs carry their size always),
so an empty cell is as tall as the table's text. Session 407.

## Usage

``` r
.jst_docx_retype(xml, font = NULL, size = NULL)
```

## Arguments

- xml:

  Character; the table's paragraphs and table, as XML.

- font:

  Character(1), or NULL to leave the font alone.

- size:

  Points, or NULL to leave the paragraph marks' size alone.

## Value

Character, as `xml`.
