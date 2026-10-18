# Internal helper: numbers as a text variable's codes, quoted

`c(-99, -98)` as `c("-99", "-98")`, names kept; a marker as its spelling
(`".a"`).

## Usage

``` r
.jst_numbers_as_text_codes(codes)
```

## Arguments

- codes:

  Numeric codes, possibly named.

## Value

Character(1), the R code.
