# Internal helper: a result's filters, in words

Internal helper: a result's filters, in words

## Usage

``` r
.jst_table_filter_text(r, minus = "true")
```

## Arguments

- r:

  A result.

- minus:

  The style's minus setting.

## Value

Character(1): the stored jsubset() filter, then the call's subset =,
joined by "and" (an or-condition in parentheses beside the other); NA
when the result had none.
