# Internal helper: the counts a bar chart shows, for its Excel sheet

Internal helper: the counts a bar chart shows, for its Excel sheet

## Usage

``` r
.jst_plot_count_sheet(
  plot_df,
  x_name,
  by_name = NULL,
  facet_name = NULL,
  by_col = NULL
)
```

## Arguments

- plot_df:

  The builder's data: x, and by, fill or facet.

- x_name, by_name, facet_name:

  The variables' names, for the heads.

- by_col:

  The column of the series ("by" or "fill"), or NULL.

## Value

A data frame: the categories, each series and panel, n, and the
percentage of the cases drawn (of each series' cases where there are
several).
