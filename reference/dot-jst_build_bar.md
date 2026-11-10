# Internal helper: build bar chart (1 categorical variable)

One series in the look's one color, each bar's count beyond its end
(ruling R70); by groups side by side, in the look's colors for that
many, their counts shown only under values.grouped = yes. The bars stand
on the axis (ruling R64).

## Usage

``` r
.jst_build_bar(
  data,
  x_name,
  by_name = NULL,
  axis_labels = NULL,
  by_label = NULL,
  facet_name = NULL,
  look = .jst_plot_look_now()
)
```
