# Internal helper: a layer of a chart's own text, marked for a redraw

The values on a chart's bars and segments and a pie's labels are drawn
in the look's font at a share of its size. A chart written to a Word
file in another style is drawn again in that style's look
([`.jst_plot_restyle()`](https://jma61.github.io/jstats/reference/dot-jst_plot_restyle.md)),
and until Session 416 its values kept the font and size they were drawn
in (the (S415) item). The mark – the text's size as a share of the
look's – is how the redraw finds the layer.

## Usage

``` r
.jst_plot_text_layer(layer, rel = 0.8)
```

## Arguments

- layer:

  A ggplot2 text layer.

- rel:

  Numeric(1); the text's size as a share of the look's size.

## Value

The layer, marked.
