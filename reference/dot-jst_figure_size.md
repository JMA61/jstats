# Internal helper: a figure's size on its page, in inches

The `[plot]` section's width and height, scaled down together when the
width is wider than the page's text or the height taller than the page
leaves beside a caption and a note, so the picture's text stays the size
the style gives it.

## Usage

``` r
.jst_figure_size(look, page)
```

## Arguments

- look:

  The figure's look.

- page:

  The page
  ([`.jst_docx_page()`](https://jma61.github.io/jstats/reference/dot-jst_docx_page.md)).

## Value

Numeric, named w and h.
