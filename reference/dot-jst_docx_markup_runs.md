# Internal helper: the runs of a marked-up line

Reads the light markup: *text* italic, ^text^ superscript. Under an
italic base (an apa caption's title) *text* is set upright, as a word
that would be italic is set inside italic text.

## Usage

``` r
.jst_docx_markup_runs(s, size = NULL, bold = FALSE, italic = FALSE)
```

## Arguments

- s:

  Character(1); the line.

- size:

  Points.

- bold, italic:

  Logical; the base style of the line (Session 403: a caption's title, a
  fit row's label).
