# Internal helper: convert a character `codes` vector to canonical form

Converts a character `codes` vector (as accepted by `jdeclare_udm`) into
the canonical numeric / tagged-NA form, so a caller can write
`codes = c("Refused" = ".a")` or `c(".a", ".b")` without
[`haven::tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html).
A token `".a"` becomes `haven::tagged_na("a")`; a numeric string such as
`"-99"` becomes `-99`. Names (label text, when present) are preserved.

## Usage

``` r
.jst_parse_code_tokens(codes)
```

## Arguments

- codes:

  Character vector of codes; each element is a Stata-style missing-value
  token (`.a` through `.z`) or a numeric string.

## Value

A numeric vector (with tagged-NA values for token entries), carrying the
names of `codes`.
