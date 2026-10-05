# Internal helper: which cells of a text vector are blank?

TRUE for a non-missing cell holding nothing once spaces, tabs and line
ends are removed –
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
definition of a blank cell
([`trimws()`](https://rdrr.io/r/base/trimws.html)'s default whitespace).
Matched by bytes, so text in any encoding is read without a conversion.

## Usage

``` r
.jst_is_blank(x)
```

## Arguments

- x:

  A character vector (a character-backed haven-labelled vector is read
  through its stored values).

## Value

A logical vector the length of `x`; FALSE for NA.
