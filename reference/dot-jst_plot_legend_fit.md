# Internal helper: the rows, labels and title of a legend above a chart

One row where the keys and their labels fit the room there is, else two
(ruling R68: "two rows when it must"). Before a label is broken the
legend's title, which stands at the keys' left, is put on shorter lines
(14 columns), which costs a two-row legend no height; only then are the
labels put on lines as short as it takes for two rows to fit – 22
columns, 18, 14 or 11. The widths are reckoned from the text
([`.jst_plot_text_in()`](https://jma61.github.io/jstats/reference/dot-jst_plot_text_in.md)):
a legend's text is drawn at eight tenths of the look's size and its
title at the whole size; each key takes about four tenths of an inch
with its spacing; and a legend's keys stand in columns, each as wide as
its widest key.

## Usage

``` r
.jst_plot_legend_fit(labels, title, look, room = look$width)
```

## Arguments

- labels:

  Character; the keys' labels, in the segments' order.

- title:

  Character(1) or NULL; the legend's title.

- look:

  A look.

- room:

  Numeric(1); the width the legend may take, in inches.

## Value

A list: rows (1 or 2), labels (the labels as drawn, named by the labels
given) and title (the title as drawn, or NULL).
