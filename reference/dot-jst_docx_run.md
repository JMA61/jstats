# Internal helper: one run of text

Internal helper: one run of text

## Usage

``` r
.jst_docx_run(
  text,
  bold = FALSE,
  italic = FALSE,
  superscript = FALSE,
  color = NULL,
  size = NULL,
  tab = FALSE
)
```

## Arguments

- text:

  The text; "" gives an empty run.

- bold, italic, superscript:

  Logical.

- color:

  A six-digit hex colour, or NULL.

- size:

  Points, or NULL for the document default.

- tab:

  Logical; TRUE writes a tab character before the text.
