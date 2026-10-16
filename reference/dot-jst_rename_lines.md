# Internal: the arrow lines of a rename note

One line per changed name: the old name in double quotes (so an outer
space shows), padded to a column, then the new name, and an optional
third column. Two spaces always sit before the arrow, so the wrapper
reads each line as a layout line and passes it whole
(.jst_seg_category()).

## Usage

``` r
.jst_rename_lines(old, new, why = NULL)
```

## Arguments

- old, new:

  Character vectors.

- why:

  Optional character vector, a third column.

## Value

Character vector.
