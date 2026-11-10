# Internal helper: the parts of a document file

Internal helper: the parts of a document file

## Usage

``` r
.jst_docx_parts(tables, style, landscape = NULL)
```

## Arguments

- tables:

  A list of jst_table and jst_figure.

- style:

  The style list.

- landscape:

  NULL, or the page setting for every page (the writing call's).

## Value

A named list of parts: path in the package, then the text, or a
picture's bytes.
