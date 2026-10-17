# Internal: a list of at most five, then a count

"4", "4 and 7", "4, 7, and 9" up to `max_show`; past it, "4, 7, 9, 12,
15 and 3 more" – the CSV shape check's form for the lines it names.

## Usage

``` r
.jst_short_list(x, max_show = 5L)
```

## Arguments

- x:

  A vector.

- max_show:

  How many to name.

## Value

Character(1).
