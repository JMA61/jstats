# Internal helper: strip optional surrounding quotes from a map word

Map words take optional quoting, required when the word contains a
semicolon, an equals sign, or a comma. Quoting also makes a reserved
word literal: bare `NA`, `else`, and `blank` are keywords, while `"NA"`,
`'else'`, and `"blank"` are ordinary data words. The caller therefore
needs to know not just the text but whether it arrived quoted. Outer
whitespace is trimmed either way, matching the trim applied to the data
side.

## Usage

``` r
.jst_unquote_word(s)
```

## Arguments

- s:

  Character scalar. One raw left-hand-side piece.

## Value

A list with `text` (the word, unquoted and trimmed) and `quoted`
(logical).
