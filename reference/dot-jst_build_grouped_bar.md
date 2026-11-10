# Internal helper: build grouped bar chart (2 categorical variables)

The second variable's categories side by side in the look's colors for
that many, their counts shown only under values.grouped = yes (ruling
R70: no values on a chart of several series by default); the bars stand
on the axis.

## Usage

``` r
.jst_build_grouped_bar(
  data,
  variable_names,
  axis_labels = NULL,
  facet_name = NULL,
  look = .jst_plot_look_now()
)
```
