# Internal helper: the points a model's or a test's plot draws, for its Excel sheet

The plot's own data frame, the columns jstats built it with (ruling R65:
a figure's data to Excel), each a number or text.

## Usage

``` r
.jst_plot_points_sheet(p)
```

## Arguments

- p:

  A ggplot.

## Value

A data frame, or NULL.
