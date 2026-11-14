# Internal helper: jsave() given a chart

Session 429 (Claude's recommendation, okayed with the build): a chart
kept with \<- – jplot()'s, or one drawn in ggplot2 – is not saved. Its
place is a Word file, through jtable() as a figure, and a chart kept as
an R object holds its data and can fail to draw after ggplot2 is
updated, while the line that drew it draws it again.

## Usage

``` r
.jst_chart_save_stop(data_sub)
```

## Arguments

- data_sub:

  The data argument as typed.
