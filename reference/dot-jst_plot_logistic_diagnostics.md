# Produce diagnostic plots for a binary logistic regression

Internal helper called by
[`jplot.jst_logistic()`](https://jma61.github.io/jstats/reference/jplot.md)
to generate diagnostic plots appropriate for binary outcomes. Unlike
standard linear-regression residual plots, these are designed for the
structure of a logistic model.

## Usage

``` r
.jst_plot_logistic_diagnostics(model, which, n_label = 3)
```

## Arguments

- model:

  A fitted `glm` object with `family = binomial`.

- which:

  Character vector of diagnostic names. Any subset of `binned`, `roc`,
  `calibration`, `cooks`, `leverage`.

- n_label:

  Integer. Number of extreme observations to label on relevant plots.
  Default 3.

## Value

Invisibly, a named list of `ggplot` objects corresponding to the
requested plots. Returns `NULL` invisibly if ggplot2 is not available.

## Details

Produces any subset of five plots: binned residuals, ROC curve,
calibration plot, Cook's distance, and residuals vs leverage.

Each plot is printed to the current device. Returns the plots invisibly
as a named list so callers can capture or modify them.
