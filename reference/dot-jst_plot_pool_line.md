# Internal helper: the N line of a chart of several items

A 100% stacked bar of a set of items counts each item on its own valid
answers, as jfreq() counts each variable, so its N statement is the
per-variable layout's (the S412 audit's F18): the cases in the pool and
the number of items, with those complete on every item when the items'
Ns differ, and the cases a filter left out beside it.

## Usage

``` r
.jst_plot_pool_line(data, items, n_original)
```

## Arguments

- data:

  The frame the chart is drawn from, after the pipeline.

- items:

  Character; the items.

- n_original:

  Integer; the data frame's rows before the pipeline.

## Value

Each item's valid N, invisibly; prints the line.
