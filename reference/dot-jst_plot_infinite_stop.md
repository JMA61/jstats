# Internal helper: jplot()'s stop on infinite values it cannot draw

Session 394 (the (S392) infinite-value item). A histogram, a density
plot, a scatterplot and a box plot's numeric side cannot place Inf or
-Inf: ggplot2 left the case out under its "Removed 1 rows containing
non-finite values" warning, while the N line above counted it. The
analyses' stop
([`.jst_stop_infinite()`](https://jma61.github.io/jstats/reference/dot-jst_stop_infinite.md))
on the cases the N line counts, for the variables drawn on a numeric
scale. A bar chart draws a value as a category, -Inf among them, and is
not stopped.

## Usage

``` r
.jst_plot_infinite_stop(data, drawn, numeric_vars, type, data_name)
```

## Arguments

- data:

  The frame the plot is drawn from, after the pipeline.

- drawn:

  Character; every variable the plot draws (the N line's).

- numeric_vars:

  Character; those drawn on a numeric scale.

- type:

  Character(1); the resolved plot type.

- data_name:

  Character or NULL; the data frame's name.

## Value

Invisibly NULL, or never returns.
