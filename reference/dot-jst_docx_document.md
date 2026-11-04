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
