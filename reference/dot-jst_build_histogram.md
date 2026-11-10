# Internal helper: build histogram (1 numeric variable)

One series in the look's one color; by groups laid over each other in
its colors for that many; bins standing on the axis (ruling R64). A
builder returns the chart with the scales that carry its colors
([`.jst_plot_built()`](https://jma61.github.io/jstats/reference/dot-jst_plot_built.md)).

## Usage

``` r
.jst_build_histogram(
  data,
  x_name,
  by_name = NULL,
  axis_labels = NULL,
  by_label = NULL,
  facet_name = NULL,
  look = .jst_plot_look_now()
)
```
