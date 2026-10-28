# Internal helper: the descriptives table from one or more jdesc() results

Rows from `.jst_apa_terms()` on each result in turn, so several results
stack into one table. Role headings come from `headings` (a named list
of variables) or from the names of a list of results; under a heading
its variables are indented. The columns are the style's descriptives
columns; a mean and an SD take the style's decimals, a minimum and a
maximum the places the data carry (they are values of the variable, not
statistics), n is a count. The general note opens on N (the cases in the
pool) when note.n is yes, then carries the user's text; each specific
note's mark is assigned by the style (letters or symbols) and set on its
rows' labels.

## Usage

``` r
.jst_table_build_desc(
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

  A list of jst_desc results; names are headings.

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
