# Internal helper: the counts a 100% stacked bar is drawn from

Ruling R68's two data-first routes. A SET OF ITEMS, one bar per item:
the items must share their categories – labelled items the same
value-label set, an unlabelled item's values among it, and items of one
kind (the Session 414 lean) – or the call stops with the by = line. Each
bar's whole is that item's valid answers. A VARIABLE WITHIN GROUPS, one
bar per group of by =, the whole each group's cases with a value on the
variable. A variable of more than 20 values stops, as it stops
jcrosstab(), unless categorical = names it.

## Usage

``` r
.jst_plot_stacked_counts(
  data,
  items,
  by = NULL,
  as_numbers = character(0),
  asserted = character(0),
  call = NULL
)
```

## Arguments

- data:

  The frame after the pipeline.

- items:

  Character; the variables stacked.

- by:

  NULL, or the grouping variable as a factor, one value per row of data.

- as_numbers:

  Character; the items the call asserts as numeric.

- asserted:

  Character; the items categorical = names.

- call:

  The call as typed, for the line the 20-value stop offers.

## Value

A list: cells (bar, cat, n, as factors and a count), bars and cats
(their names in order) and ns (each bar's whole).
