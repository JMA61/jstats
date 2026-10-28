# Internal helper: the body of a document holding tables

Each table's caption, table and notes (paragraphs or rows by the style),
an empty paragraph between tables, and the section properties: the page,
landscape when the style says so or when auto finds the table wider than
the portrait text width.

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
