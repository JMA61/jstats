# Internal helper: a figure's block in the document, as XML

The frame (ruling R63): a borderless table of one column as wide as the
picture, its rows the caption (when caption.position = row), the picture
and the note (when note.position = row and there is one); a caption or a
note set as a paragraph goes before or after the table, as a table's
does. Every row is kept with the next and none splits, so the caption,
the chart and the note stay on one page. The picture's description for a
screen reader is the figure's title.

## Usage

``` r
.jst_docx_figure(fig, L, number, rid, id)
```

## Arguments

- fig:

  A jst_figure.

- L:

  Its layout
  ([`.jst_figure_layout()`](https://jma61.github.io/jstats/reference/dot-jst_figure_layout.md)).

- number:

  The figure's number.

- rid:

  The picture's relationship id.

- id:

  The picture's number among the document's drawings.

## Value

Character; the block's XML.
