# Internal helper: a fill or color scale in a look's colors

Every color a chart of variables draws comes from one of these scales –
a single series as a constant mapped to its one color, guide off – so
jtable() can draw the chart again in another style's colors by adding
the scale again
([`.jst_plot_restyle()`](https://jma61.github.io/jstats/reference/dot-jst_plot_restyle.md)).

## Usage

``` r
.jst_plot_scale(
  aes,
  levels,
  look,
  guide = TRUE,
  contrast = FALSE,
  rows = NULL,
  breaks = NULL,
  labels = NULL
)
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

- contrast:

  TRUE for the text color that reads on each series' color.

- rows:

  NULL, or the legend's rows.

- breaks:

  NULL, or the series in the order the legend's keys are given.

- labels:

  NULL, or the keys' labels, named by series.

## Value

A ggplot2 scale.

## Details

Since Session 416 a scale may also carry what a 100% stacked bar's
needs: the black or white that reads on each series' color, for a value
written inside a segment (`contrast`); and a legend's rows, the order
its keys are given in and the labels they take (`rows`, `breaks`,
`labels`).
