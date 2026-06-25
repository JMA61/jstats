# Internal helper: add an lm regression line and optional band to a scatter

Handles the four band options: ci (ggplot default), pi (prediction
interval, computed manually), see (constant +/- t\*SEE rectangle), none.

## Usage

``` r
.jst_add_lm_line(p, plot_df, x_name, y_name, by_name, band)
```
