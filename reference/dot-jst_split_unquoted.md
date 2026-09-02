# Internal helper: split a string on a separator, ignoring quoted spans

Text maps let a word be quoted, and a quoted word may itself contain the
characters the map syntax uses as separators (`"Refused; not asked"=9`).
A plain [`strsplit()`](https://rdrr.io/r/base/strsplit.html) would cut
inside the quotes, so the map string is walked character by character
with the quote state tracked, and only unquoted separators split. Quote
marks are left in place;
[`.jst_unquote_word()`](https://jma61.github.io/jstats/reference/dot-jst_unquote_word.md)
strips them afterwards.

## Usage

``` r
.jst_split_unquoted(x, sep)
```

## Arguments

- x:

  Character scalar to split.

- sep:

  Character scalar. The single-character separator.

## Value

Character vector of pieces, carrying an `unbalanced` attribute that is
`TRUE` when a quote was opened and never closed.
