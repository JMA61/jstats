# Internal helper: the caption paragraphs of a table

Internal helper: the caption paragraphs of a table

## Usage

``` r
.jst_docx_caption_pars(tbl, style, number, color = NULL)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- number:

  The table's number.

- color:

  A six-digit hex colour for the caption's text, or NULL (Session 409:
  the header's text colour, on a caption bar that follows the header).

## Value

Character; one or two paragraphs' XML.
