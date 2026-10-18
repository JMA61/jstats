# Internal helper: numbers as a text variable's codes, as strings

The character vector
[`.jst_numbers_as_text_codes()`](https://jma61.github.io/jstats/reference/dot-jst_numbers_as_text_codes.md)
writes out: each number as R prints it, never in scientific notation; a
marker as its spelling; names kept.

## Usage

``` r
.jst_numbers_as_strings(codes)
```

## Arguments

- codes:

  Numeric codes, possibly named.

## Value

Named character vector.
