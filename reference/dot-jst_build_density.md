# Internal helper: build a density plot (1 numeric variable)

The alternative to the histogram (Capability Slate C3, Session 378): the
variable's kernel density estimate, one curve, or one per group of
`by =` laid over each other, and one panel per group of `facet =`. Never
the automatic choice: `type = "density"` asks for it. In the look's
colors since Session 415.

## Usage

``` r
.jst_build_density(
  data,
  x_name,
  by_name = NULL,
  axis_labels = NULL,
  by_label = NULL,
  facet_name = NULL,
  look = .jst_plot_look_now()
)
```
