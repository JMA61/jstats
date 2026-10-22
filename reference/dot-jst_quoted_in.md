# Internal helper: does R's message name this name between marks?

The test
[`.jst_filter_unbound()`](https://jma61.github.io/jstats/reference/dot-jst_filter_unbound.md)
has made since Session 330, given a home of its own at Session 392 so
that the expression given as the data
([`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md))
asks it the same way: the name appears in the message between two
characters that are not spaces and could not be part of a name – the
quotation marks R puts around the first missing object in every language
it is translated into. Requiring the marks keeps a one-letter name from
matching a word of the message.

## Usage

``` r
.jst_quoted_in(nm, msg)
```

## Arguments

- nm:

  Character(1). The name.

- msg:

  Character(1). R's message.

## Value

TRUE or FALSE.
