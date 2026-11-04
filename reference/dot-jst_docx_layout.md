# Internal helper: each table's page and fit in a document

Each table gets the page it needs (Session 406): the setting is its own
style's landscape (the style it was built under, a call's own setting
included), read for its table type, so a table built with landscape =
"yes" keeps its page in any document; under auto it turns only when the
table cannot fit the portrait text width at the style's size with half
its padding and its labels on two lines (ruling R55). `landscape` given
– the setting in the call that writes the document – sets every page.
Until Session 406 a document had one orientation, so one wide table
turned every page. A table wider than its page is fitted to it
([`.jst_docx_fit()`](https://jma61.github.io/jstats/reference/dot-jst_docx_fit.md)).
The paper is the document style's.

## Usage

``` r
.jst_docx_layout(tables, style, landscape = NULL)
```

## Arguments

- tables:

  A list of jst_table.

- style:

  The document's style.

- landscape:

  NULL, or "auto", "yes" or "no" for every page.

## Value

A list, one element per table: style (the table's), landscape (logical),
page, fit (widths, size and note_size; size NULL when the table fits as
it is), natural (the widths before any fit) and size0 (the style's
size).
