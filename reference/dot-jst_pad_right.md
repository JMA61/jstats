# Internal helper: pad a character vector to a common width

Right-pads with spaces so a two-column listing lines up. Used by
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
alphabetical-assignment note.

## Usage

``` r
.jst_pad_right(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector, each element padded to the longest width.
