# Internal helper: a fill or color scale in a look's colors

Every color a chart of variables draws comes from one of these scales –
a single series as a constant mapped to its one color, guide off – so
jtable() can draw the chart again in another style's colors by adding
the scale again
([`.jst_plot_restyle()`](https://jma61.github.io/jstats/reference/dot-jst_plot_restyle.md)).

## Usage

``` r
.jst_plot_scale(aes, levels, look, guide = TRUE)
```

## Arguments

- aes:

  "fill" or "colour".

- levels:

  Character; the series, in order.

- look:

  A look.

- guide:

  TRUE for a legend.

## Value

A ggplot2 scale.
