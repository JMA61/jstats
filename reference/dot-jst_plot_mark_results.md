# Internal helper: a result's plots marked as jplot()'s

Each plot gets the class and the frame's facts
([`.jst_plot_finish()`](https://jma61.github.io/jstats/reference/dot-jst_plot_finish.md)):
its kind (the plot's name: "fit", "qq", "effect_Age"), the result's N,
its default title (ruling R69: a model's or a test's plot keeps its own
title – "Residuals vs Fitted" – which stands in the caption in a Word
file; a fit plot, a box plot and a scatterplot, which have none, the
outcome "by" the predictor or the group), and what it shows without a
label (ruling R72).

## Usage

``` r
.jst_plot_mark_results(
  plots,
  x,
  n = NA,
  titles = character(0),
  shown = character(0)
)
```

## Arguments

- plots:

  A named list of ggplots.

- x:

  The result.

- n:

  Its N.

- titles:

  Named character; default titles by plot name.

- shown:

  Character; the variables the plots show.

## Value

The list, each plot marked.
