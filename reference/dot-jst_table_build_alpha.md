# Internal helper: the reliability table from one or more jalpha() results

Internal helper: the reliability table from one or more jalpha() results

## Usage

``` r
.jst_table_build_alpha(
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

  A list of jst_alpha results; names are the scales'.

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
