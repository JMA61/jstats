# Internal helper: the words of an argument typed without quotes

A bare symbol, or a [`c()`](https://rdrr.io/r/base/c.html) of symbols
and strings with at least one symbol: the words as typed and which of
them are bare. Anything else – a string, a call of another function, an
empty name – gives NULL. Shared by
[`.jst_word_args()`](https://jma61.github.io/jstats/reference/dot-jst_word_args.md)
(moved out of it, Session 377) and jplot()'s
[`.jst_resolve_which()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_which.md).

## Usage

``` r
.jst_bare_words(expr)
```

## Arguments

- expr:

  An argument's expression, unevaluated.

## Value

A list (`words`, character; `bare`, logical), or NULL.
