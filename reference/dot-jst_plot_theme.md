# Internal helper: a chart's theme in a style's look

White, its text black in the style's font and size, the axis lines and
gridlines the style names, the legend where it says with its title
(ruling R64). Every chart jplot() draws takes it, the diagnostics plots
included.

## Usage

``` r
.jst_plot_theme(look = NULL, device = NULL, flip = FALSE)
```

## Arguments

- look:

  A look; the chart being drawn's when NULL.

- device:

  As
  [`.jst_plot_family()`](https://jma61.github.io/jstats/reference/dot-jst_plot_family.md).

- flip:

  Logical(1); TRUE for a chart whose bars run across.

## Value

A complete ggplot2 theme.

## Details

A chart whose bars run across the page – the ranked bar of a
multiple-response set, a 100% stacked bar (Session 416) – has its value
axis along the bottom, so the look's gridlines and axis lines are turned
with it (`flip`): report's light gridlines run up from the values, and
its one axis line is the one the bars stand on.
