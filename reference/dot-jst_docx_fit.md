# Internal helper: a table's widths and sizes, fitted to the page

Ruling R55 (Session 404): a table wider than its page loses half its
number columns' padding; then its labels wrap onto at most two lines,
the stub narrowing as far as
[`.jst_docx_stub_floor()`](https://jma61.github.io/jstats/reference/dot-jst_docx_stub_floor.md)
allows; then its font steps down a point at a time to 8 pt, the stub at
each size allowed its floor again; then the stub narrows to an inch and
a half and every column in proportion. A number never wraps until that
last step. The notes step down with the table; the caption keeps its
size. (Until Session 405 the font stepped down before any label wrapped
– Session 402, item 11, settled on a 17-column regression table whose
numbers set its width.)

## Usage

``` r
.jst_docx_fit(tbl, style, page_text)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- page_text:

  The text width available, in dxa.

## Value

A list: widths (integer), size and note_size (points).
