# Internal helper: a legend's keys in reading order over two rows

ggplot2 lays a legend's keys out down its columns. Given in this order,
the keys of a two-row legend read left to right along the first row and
then the second, the order of the segments they name (ruling R68).

## Usage

``` r
.jst_plot_legend_order(levels, rows)
```

## Arguments

- levels:

  Character; the keys, in the segments' order.

- rows:

  Integer(1); the legend's rows.

## Value

Character; the keys in the order to give the scale.
