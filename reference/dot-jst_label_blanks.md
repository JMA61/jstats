# Internal helper: put the blank label on a text variable's blank cells

A character vector (plain or haven-labelled) comes back with every blank
cell holding `.jst_blank_label`, so the empty and the whitespace cells
are ONE value. A factor's blank levels are renamed the same way (and
merged, where there were several). Anything else is returned as it came.

## Usage

``` r
.jst_label_blanks(x)
```

## Arguments

- x:

  A variable.

## Value

`x`, relabeled where it had blank cells.
