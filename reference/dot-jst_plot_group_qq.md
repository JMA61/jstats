# Internal helper: the normal Q-Q plot of a comparison's residuals

The standardized residuals against the normal quantiles, the line of
equality dashed, the three cases farthest from 0 labeled by their row
names (by their pair's number for a paired test) – the plot
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md)'s `"qq"`
draws, for a [`jt()`](https://jma61.github.io/jstats/reference/jt.md) or
[`jaov()`](https://jma61.github.io/jstats/reference/jaov.md) result
(Session 375; ruling R14, part 2: a plot, not a test). Printed, and
returned invisibly.

## Usage

``` r
.jst_plot_group_qq(r, paired = FALSE, n_label = 3L)
```

## Arguments

- r:

  Numeric vector; the standardized residuals.

- paired:

  Logical; the residuals are a paired test's differences.

- n_label:

  Integer; the cases labeled.

## Value

Invisibly, the ggplot.
