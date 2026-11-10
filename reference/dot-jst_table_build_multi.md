# Internal helper: the multiple-response table from a jmulti() result

Rows from `.jst_apa_terms()`: each option named by the text its item's
label adds to what the set's labels share ("Housing" of "Services used:
Housing"), else by its label, else by its name; the row of those who
chose none named by the style's none.label. The columns are the style's:
n and the percentage of the set's N. The title is the style's template,
`{set}` the text the labels share, else "Options Chosen" (ruling R69); N
goes where n.position puts it; the general note carries the filter, the
more-than-100 sentence (choice.note, removable by ruling R53) and the
call's text. markers = marks an item's row.

## Usage

``` r
.jst_table_build_multi(
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

  A list of one jst_multi result.

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
