# Internal helper: a figure's page and size in a document

Portrait, unless the writing call's landscape = "yes" or the figure's
style says yes: a picture is scaled to its page, so auto never turns
one.

## Usage

``` r
.jst_figure_layout(fig, paper, landscape = NULL)
```

## Arguments

- fig:

  A jst_figure.

- paper:

  The document's paper.

- landscape:

  NULL, or the writing call's page setting.

## Value

A list as
[`.jst_docx_layout()`](https://jma61.github.io/jstats/reference/dot-jst_docx_layout.md)
gives a table, with the figure's look and its size in inches in place of
the fit.
