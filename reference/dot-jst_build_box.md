# Internal helper: build boxplot (1 numeric + 1 categorical)

One series light grey with black lines, the mean a black diamond (the
fixed greys of ruling R64); by groups, the boxes in the look's colors
for that many.

## Usage

``` r
.jst_build_box(
  data,
  variable_names,
  var_types,
  by_name = NULL,
  axis_labels = NULL,
  by_label = NULL,
  look = .jst_plot_look_now()
)
```
