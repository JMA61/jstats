# Internal helper: a text variable as a factor, the blank category first

`factor(x)` for a plain character vector, with two differences: blank
cells are one level, labeled `.jst_blank_label`, and that level comes
FIRST whatever the session's sort order would make of the angle bracket
(a locale's collation can ignore punctuation, which would file between
"Adult" and "Juvenile" on one machine and ahead of both on another). Any
other input is `factor(x)`.

## Usage

``` r
.jst_text_factor(x)
```

## Arguments

- x:

  A variable.

## Value

A factor.
