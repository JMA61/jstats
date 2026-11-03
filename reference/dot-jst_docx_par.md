# Internal helper: one paragraph

Internal helper: one paragraph

## Usage

``` r
.jst_docx_par(
  runs,
  style = NULL,
  jc = NULL,
  ind = NULL,
  tab = NULL,
  keep_next = FALSE,
  spacing_after = NULL,
  line = "single",
  size = NULL
)
```

## Arguments

- runs:

  The runs' XML, pasted.

- style:

  A paragraph style id, or NULL.

- jc:

  "left", "center" or "right", or NULL.

- ind:

  Left indent in dxa, or NULL.

- tab:

  A decimal tab position in dxa, or NULL.

- keep_next:

  Logical.

- spacing_after:

  Points after the paragraph, or NULL.

- line:

  "single" or "double".

- size:

  Points, or NULL: the paragraph mark's size, which sets the height of
  an EMPTY cell – given when a table is fitted to the page at a size
  below the document's, so an empty cell does not hold its row at the
  larger height (Session 403).
