# Internal helper: a radix order for text, whatever its encoding mark

Session 390 (the non-English probe): R's radix sort refuses a vector
whose first non-missing string is not ASCII and carries no encoding mark
("Character encoding must be UTF-8, Latin-1 or bytes"), on every
platform, and text read from a CSV file – by jload() or read.csv() – or
typed into a script that is source()d carries none. jencode() on a CSV
variable whose first word was Zurich spelled with its umlaut, or a word
in Chinese, stopped in R's words. Each character key is given its UTF-8
mark first ([`enc2utf8()`](https://rdrr.io/r/base/Encoding.html), which
in a UTF-8 session only marks the text), so the order is the radix order
of the same bytes.

## Usage

``` r
.jst_text_order(..., decreasing = FALSE)
```

## Arguments

- ...:

  The keys, as [`order()`](https://rdrr.io/r/base/order.html) takes
  them.

- decreasing:

  As [`order()`](https://rdrr.io/r/base/order.html)'s.

## Value

Integer permutation, as `order(..., method = "radix")`.
