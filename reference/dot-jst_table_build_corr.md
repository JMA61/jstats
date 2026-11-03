# Internal helper: the correlation table from a jcorr() result

Internal helper: the correlation table from a jcorr() result

## Usage

``` r
.jst_table_build_corr(
  results,
  style,
  headings = NULL,
  markers = NULL,
  title = NULL,
  note = NULL
)
```

## Arguments

- results:

  A list holding one jst_corr result.

- style:

  The style list.

- headings:

  A named list: each heading's variables (or NULL).

- markers:

  A named list: each specific note's variables (or NULL).

- title:

  The user's title, or NULL for the type's template.

- note:

  The user's general note, or NULL.

## Value

A jst_table.
