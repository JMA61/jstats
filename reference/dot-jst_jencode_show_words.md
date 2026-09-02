# Internal helper: render a capped, quoted word list for a message

Renders words as a natural quoted list, truncating at `max_show` with
Rule A's "and N more" tail so a message stays readable when a column
carries many distinct words. Used by
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
unmapped-word naming and its target-side minting note.

## Usage

``` r
.jst_jencode_show_words(x, max_show = 5L)
```

## Arguments

- x:

  Character vector of words.

- max_show:

  Integer. How many words to name before truncating.

## Value

Character scalar.
