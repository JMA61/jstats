# Internal helper: the width a text needs in a cell, in dxa

Internal helper: the width a text needs in a cell, in dxa

## Usage

``` r
.jst_docx_text_width(s, size, digits = FALSE, font = NULL, bold = FALSE)
```

## Arguments

- s:

  Character; the texts.

- size:

  Points.

- digits:

  Logical; TRUE for a number column (a digit is about half an em), FALSE
  for text (a letter a little less).

- font:

  Character(1), or NULL: the face measured in (Session 407).

- bold:

  Logical; TRUE for bold text, which is up to about 8 percent wider than
  the same text upright (Arial's bold; Times's about 6).
