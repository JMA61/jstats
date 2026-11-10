# Internal helper: print a figure to the console

The caption and the note as the Word file sets them, in the style's
caption form, and the picture as the Word file holds it drawn on the
plot device (the Plots pane in RStudio): the title in the caption, not
the picture.

## Usage

``` r
.jst_figure_preview(fig, number = 1L, draw = TRUE)
```

## Arguments

- fig:

  A jst_figure.

- number:

  The figure's number.

- draw:

  Logical; FALSE prints the words only.
