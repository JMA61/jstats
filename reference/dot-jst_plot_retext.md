# Internal helper: a chart's own text drawn again in another look

Each layer
[`.jst_plot_text_layer()`](https://jma61.github.io/jstats/reference/dot-jst_plot_text_layer.md)
marked is replaced by a copy of itself in the look's font and at its
share of the look's size. The copy inherits everything else from the
layer, which is left as it was, so the chart the user holds does not
change.

## Usage

``` r
.jst_plot_retext(p, look, device = NULL)
```

## Arguments

- p:

  A chart jplot() drew.

- look:

  The look to draw its text in.

- device:

  As
  [`.jst_plot_family()`](https://jma61.github.io/jstats/reference/dot-jst_plot_family.md).

## Value

The chart.
