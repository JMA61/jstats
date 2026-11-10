# Internal helper: add an lm regression line and optional band to a scatter

Handles the four band options: ci (ggplot default), pi (prediction
interval, computed manually), see (constant +/- t\*SEE rectangle), none.
The line and its band take the series' color through the chart's color
scales (Session 415).

## Usage

``` r
.jst_add_lm_line(p, plot_df, x_name, y_name, by_name, band)
```
