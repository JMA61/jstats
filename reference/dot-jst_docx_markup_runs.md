# Internal helper: the runs of a marked-up line

Reads the light markup: *text* italic, ^text^ superscript. Under an
italic base (an apa caption's title) *text* is set upright, as a word
that would be italic is set inside italic text.

## Usage

``` r
.jst_docx_markup_runs(
  s,
  size = NULL,
  bold = FALSE,
  italic = FALSE,
  color = NULL,
  keep = FALSE
)
```

## Arguments

- s:

  Character(1); the line.

- size:

  Points.

- bold, italic:

  Logical; the base style of the line (Session 403: a caption's title, a
  fit row's label).

- color:

  A six-digit hex colour, or NULL (Session 405: a column head with
  markup takes the header's colour).

- keep:

  Logical; TRUE for a row's label
  ([`.jst_docx_keep_text()`](https://jma61.github.io/jstats/reference/dot-jst_docx_keep_text.md)).
