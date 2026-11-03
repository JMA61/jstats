# Internal helper: the body of a document holding tables

Each table's caption, table and notes (paragraphs or rows by the style),
two empty paragraphs between tables (Jeff, Session 401), and the section
properties: the page, landscape when the style – or the call, since
Session 403 – says so, or when auto finds a table wider than the
portrait text width; a table wider than the page fitted to it
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
