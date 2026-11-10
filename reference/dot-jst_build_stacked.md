# Internal helper: draw a 100% stacked bar

Ruling R68 (Session 412; its orientation ruled Session 413): horizontal
bars in their natural order, the first at the top; each bar's segments
its categories in order, dark to light, summing to 100 percent of the
bar's whole; the look's axes and gridlines, turned for bars that run
across; the legend ABOVE the chart in the segments' order, in both
built-in styles (an amendment of ruling R64 for this kind). No values in
the segments unless the style's values.stacked says yes, and then none
in a segment under 6 percent (ruling R70).

## Usage

``` r
.jst_build_stacked(
  counts,
  bar_labels = NULL,
  bar_title = NULL,
  legend_title = NULL,
  sheet_names = c("Group", "Category"),
  look = .jst_plot_look_now()
)
```

## Arguments

- counts:

  A list as
  [`.jst_plot_stacked_counts()`](https://jma61.github.io/jstats/reference/dot-jst_plot_stacked_counts.md)
  returns.

- bar_labels:

  Named character; each bar's label on the axis.

- bar_title:

  Character(1) or NULL; the title of the bars' axis.

- legend_title:

  Character(1) or NULL.

- sheet_names:

  Character(2); the heads of the data sheet's bar and category columns.

- look:

  A look.

## Value

The chart, as a builder returns it
([`.jst_plot_built()`](https://jma61.github.io/jstats/reference/dot-jst_plot_built.md)).
