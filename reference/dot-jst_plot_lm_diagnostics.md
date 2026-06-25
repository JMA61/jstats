# Internal helper: produce diagnostic plots for a fitted linear model

Generates five diagnostic plots using ggplot2. Each plot is printed
sequentially and appears in the RStudio Plots pane.

## Usage

``` r
.jst_plot_lm_diagnostics(model, which, n_label = 3)
```

## Arguments

- model:

  A fitted `lm` object.

- which:

  Character vector of plot types to produce. Options: "residuals"
  (residuals vs fitted), "qq" (normal Q-Q), "scale" (scale-location),
  "cooks" (Cook's distance), "leverage" (residuals vs leverage).

- n_label:

  Integer. Number of extreme points to label on each plot.
