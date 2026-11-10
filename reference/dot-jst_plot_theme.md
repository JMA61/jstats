# Internal helper: a chart's theme in a style's look

White, its text black in the style's font and size, the axis lines and
gridlines the style names, the legend where it says with its title
(ruling R64). Every chart jplot() draws takes it, the diagnostics plots
included.

## Usage

``` r
.jst_plot_theme(look = NULL, device = NULL)
```

## Arguments

- look:

  A look; the chart being drawn's when NULL.

- device:

  As
  [`.jst_plot_family()`](https://jma61.github.io/jstats/reference/dot-jst_plot_family.md).

## Value

A complete ggplot2 theme.
