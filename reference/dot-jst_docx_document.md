# Internal helper: the body of a document holding tables

Each table's caption, table and notes (paragraphs or rows by the style),
two empty paragraphs between tables (Jeff, Session 401), and the section
properties. Since Session 406 each table has the page it needs
([`.jst_docx_layout()`](https://jma61.github.io/jstats/reference/dot-jst_docx_layout.md)):
where the orientation changes between two tables, the second empty
paragraph ends a section, and Word starts the next table on a new page
turned its own way; tables in a row with the same orientation share
pages. Until then one orientation served the whole document: landscape
when the style – or the call, since Session 403 – said so, or when auto
found any table that could not fit the portrait text width at the
style's size with half its padding and its labels on two lines (ruling
R55, Session 404).

## Usage

``` r
.jst_docx_document(tables, style, landscape = NULL)
```

## Arguments

- tables:

  A list of jst_table.

- style:

  The style list.

- landscape:

  NULL, or "auto", "yes" or "no" for every page (the writing call's
  setting).

## Value

A list: xml (the document part) and landscape (logical, one per table).

## Details

Each table keeps its own style's font (Session 407, the (S406) item):
the document's defaults are its style's – the first table's, for built
tables written together – and a table whose style sets another font, or
another size, has it written on its own runs and paragraph marks
([`.jst_docx_retype()`](https://jma61.github.io/jstats/reference/dot-jst_docx_retype.md)).
Until then the defaults alone carried the font, so the second table of a
document written under two styles took the first one's font while its
fills, rules and captions followed its own style. A table in the
document's font and size is written as before.
