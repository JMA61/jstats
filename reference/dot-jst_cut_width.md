# Internal helper: the longest start of a string within a display width

Session 390: the cut for a label too wide for its column. It keeps whole
characters up to `width` console columns – a two-column character that
would straddle the edge is left out, so the result can be one column
narrower – and a combining accent stays with its letter. Plain ASCII is
cut as `substr(s, 1, width)` cuts it.

## Usage

``` r
.jst_cut_width(s, width)
```

## Arguments

- s:

  Character scalar.

- width:

  Whole number of columns.

## Value

Character scalar.
