# Internal helper: a 100% stacked bar's legend, fitted to a look

The legend above the chart (ruling R68), from the picture's left edge:
ggplot2 sets a legend above a chart from the left edge of the bars, so
it is moved left by about the width of the bars' labels, which leaves it
the picture's width. The move is reckoned a little short, so the legend
never starts off the picture, and the room it is fitted to
([`.jst_plot_legend_fit()`](https://jma61.github.io/jstats/reference/dot-jst_plot_legend_fit.md))
is short by as much. Called when the chart is built and again when it is
drawn in another style's look
([`.jst_plot_restyle()`](https://jma61.github.io/jstats/reference/dot-jst_plot_restyle.md)),
whose text may be larger or whose figure narrower.

## Usage

``` r
.jst_plot_stacked_legend(cats, legend_title, axis_lab, bar_title, values, look)
```

## Arguments

- cats:

  Character; the segments' categories, in order.

- legend_title:

  Character(1) or NULL, as drawn.

- axis_lab:

  Character; the bars' labels, as drawn.

- bar_title:

  Character(1) or NULL; the title of the bars' axis.

- values:

  Logical(1); whether the segments hold their values, whose text takes a
  color scale of its own.

- look:

  A look.

## Value

A list: scales (the chart's scale specs), tweak (the theme settings
added after the look's theme) and title (the legend's title as it is
drawn, or NULL).
