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
  line = "single"
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
