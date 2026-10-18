# Internal: values a text variable holds that differ from a declared one only in case or outer spaces

Ruling R26's lean 2: codes match exactly, as in SPSS, and the values
that differ from a declared code only in letter case or outer spaces are
named after declaring, with their counts, most cases first.

## Usage

``` r
.jst_text_near_misses(col, codes)
```

## Arguments

- col:

  The variable.

- codes:

  The declared strings.

## Value

NULL, or a list of `values` and `n`.
