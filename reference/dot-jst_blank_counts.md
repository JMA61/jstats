# Internal helper: count a text variable's blank cells, by kind

Internal helper: count a text variable's blank cells, by kind

## Usage

``` r
.jst_blank_counts(x)
```

## Arguments

- x:

  A variable: a character vector, or a factor (read by its level text);
  anything else counts zero.

## Value

A list: `n` blank cells, of which `empty` hold an empty string and
`space` only spaces, tabs or line ends.
