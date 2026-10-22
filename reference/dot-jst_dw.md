# Internal helper: the display width of text, in console columns

Session 390 (the non-English probe): the one measure of how wide text
prints. A Chinese, Japanese or Korean character takes two columns of a
console, a combining accent none, and every other character one, so a
count of CHARACTERS – [`nchar()`](https://rdrr.io/r/base/nchar.html)'s
default – laid every table, note and printed call holding a name or
label in those scripts out one column short for each wide character.
This is `nchar(type = "width")`, the width R's own print() and
[`format()`](https://rdrr.io/r/base/format.html) pad to; a cell is
padded with [`formatC()`](https://rdrr.io/r/base/formatc.html), which
passes character data to
[`format.default()`](https://rdrr.io/r/base/format.html) and so pads by
display width too. Plain ASCII text is as wide as it is long, so output
in English is unchanged byte for byte. A missing string is NA, as
[`nchar()`](https://rdrr.io/r/base/nchar.html) gives it (the "width"
type alone would give 2), so a caller's handling of NA is unchanged.

## Usage

``` r
.jst_dw(x)
```

## Arguments

- x:

  Character vector.

## Value

Integer vector of display widths, NA where `x` is NA.
