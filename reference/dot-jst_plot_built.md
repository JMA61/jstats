# Internal helper: a builder's chart, with the scales that carry its colors

Internal helper: a builder's chart, with the scales that carry its
colors

## Usage

``` r
.jst_plot_built(
  p,
  scales,
  data = NULL,
  flip = FALSE,
  tweak = NULL,
  relook = NULL
)
```

## Arguments

- p:

  The ggplot.

- scales:

  The scales
  ([`.jst_plot_add_scales()`](https://jma61.github.io/jstats/reference/dot-jst_plot_add_scales.md)).

- data:

  The numbers it shows, for the Excel sheet, or NULL.

- flip:

  TRUE for a chart whose bars run across.

- tweak:

  NULL, or a theme setting of the chart's own, added again when the
  chart is drawn in another look.
