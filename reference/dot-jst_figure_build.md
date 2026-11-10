# Internal helper: a chart made a figure

The frame's facts, read once, when the figure is made (rulings R63, R69,
R71): the style it is framed in – the call's `style =`; else, for a
chart jplot() drew, the style it was drawn in, so the Word file shows
what the Plots pane showed; else the session's – its title, N after it
(the chart's analysis N; the S412 audit's F7), the general note (N where
n.position puts it, the filter the chart was drawn under, the call's
note) and the call's source. A chart drawn in ggplot2 by hand has no N,
no filter and no data sheet; its look stays its own.

## Usage

``` r
.jst_figure_build(p, style = NULL, title = NULL, note = NULL, source = NULL)
```

## Arguments

- p:

  The chart.

- style:

  The call's style, resolved, or NULL.

- title, note, source:

  As [`jtable()`](https://jma61.github.io/jstats/reference/jtable.md)'s.

## Value

An object of class "jst_figure".

## Details

The title: the call's `title =`; else the title in the chart's picture
(a result plot's own, "Residuals vs Fitted", or one added with
`+ labs(title = )`), which moves to the caption; else jplot()'s default
from labels (ruling R69); else none.
