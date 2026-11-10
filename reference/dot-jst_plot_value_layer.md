# Internal helper: the values on a chart's bars

Each bar's count just beyond its end (ruling R70): on a chart of one
series under the style's values = yes, on a chart of several series –
dodged side by side – under values.grouped = yes. Whole numbers, in the
chart's font at its axis labels' size.

## Usage

``` r
.jst_plot_value_layer(look, grouped = FALSE, group_var = NULL)
```

## Arguments

- look:

  A look.

- grouped:

  Logical(1): several series, dodged.

- group_var:

  The variable the bars are dodged by ("by" or "fill").

## Value

A ggplot2 layer, or NULL when the style shows no values.
