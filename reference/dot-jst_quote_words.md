# Internal helper: render words as a double-quoted comma list

The house rendering for a list of data words in a runtime message.
Double quotes make trailing and leading spaces visible, which is the
whole point when the message is about words that did or did not match.

## Usage

``` r
.jst_quote_words(x)
```

## Arguments

- x:

  Character vector of words.

## Value

Character scalar.
