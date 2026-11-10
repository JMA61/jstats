# Internal helper: draw a jplot() chart again in another style's look

At write time (the S412 audit's F6): the chart's theme replaced by the
writing style's, its color scales added again in that style's colors,
and its look recorded. Everything else the chart holds – a title or a
layer added with `+` – is kept. A chart drawn in that look comes back as
it is, so a theme setting the user added with `+` – a font that has
Chinese characters, as the guides' Troubleshooting page gives it – stays
in the Word file; in another look the chart takes that look's theme in
place of its own. The same look is the same font, size, colors,
gridlines, axis lines and legend, with the font drawn as the same family
on the device the picture is drawn on.

## Usage

``` r
.jst_plot_restyle(p, look, device = NULL)
```

## Arguments

- p:

  A chart jplot() drew.

- look:

  The writing style's look.

- device:

  As
  [`.jst_plot_family()`](https://jma61.github.io/jstats/reference/dot-jst_plot_family.md).

## Value

The chart.
