# Internal helper: count the points ggplot2 leaves out of each plot

ggplot2 warns, as each plot is drawn, when a layer cannot draw a row –
"Removed 1 rows containing missing values (`geom_point()`)" (3.4), "...
or values outside the scale range" (3.5) – once per layer, so one case
the diagnostic plots cannot place gave six raw warnings, held to the end
of the output at R's default warn = 0 (Session 359; the S347 warnings
item's last part). The tracker takes those warnings as each plot is
printed and builds one note naming the plots and the cases they leave
out, the cause stated when every one of them has a leverage of 1 (its
standardized residual and Cook's distance are undefined: the only case
in its category). Any other warning passes.

## Usage

``` r
.jst_gg_removed_tracker()
```

## Value

A list of two functions: `take(w, title)`, TRUE when `w` is a removal
warning (recorded under the plot's title), and `note(leverage)`, the
note or `character(0)`.
