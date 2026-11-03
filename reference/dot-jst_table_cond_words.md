# Internal helper: a parsed condition in words, or NULL

The walk
[`.jst_table_filter_words()`](https://jma61.github.io/jstats/reference/dot-jst_table_filter_words.md)
runs: NULL as soon as any part cannot be put into words, so a condition
is written wholly in words or wholly as typed. A value is read only from
what was typed – a number, a string, TRUE or FALSE, c() and : of them –
never evaluated.

## Usage

``` r
.jst_table_cond_words(ex, data, minus = "true")
```

## Arguments

- ex:

  The parsed condition.

- data:

  The data frame.

- minus:

  The style's minus setting.

## Value

Character(1), or NULL.
