# Internal helper: the body of a document holding tables

Each table's caption, table and notes (paragraphs or rows by the style),
two empty paragraphs between tables (Jeff, Session 401), and the section
properties: the page, landscape when the style – or the call, since
Session 403 – says so, or when auto finds a table that cannot fit the
portrait text width at the style's size with half its padding and its
labels on two lines (ruling R55, Session 404; until Session 405, any
table wider than portrait at its natural width); a table wider than the
page fitted to it
([`.jst_docx_fit()`](https://jma61.github.io/jstats/reference/dot-jst_docx_fit.md)).

## Usage

``` r
.jst_docx_document(tables, style)
```

## Arguments

- tables:

  A list of jst_table.

- style:

  The style list.

## Value

A list: xml (the document part) and landscape (logical).
