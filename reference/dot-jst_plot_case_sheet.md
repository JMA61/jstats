# Internal helper: the cases a chart draws, for its Excel sheet

A histogram, a density plot, a scatterplot and a box plot draw cases, so
their sheet (ruling R65, the `[plot]` section's data.file) holds the
values each case is drawn at, one row per case, each column named by its
variable: a category as the chart labels it, a number as the number.

## Usage

``` r
.jst_plot_case_sheet(df, names)
```

## Arguments

- df:

  The builder's frame (columns x, y, by, facet).

- names:

  Named character: the variable each column shows; a NULL entry drops
  out.

## Value

A data frame.
