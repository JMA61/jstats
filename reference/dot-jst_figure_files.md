# Internal helper: the files written beside the Word file for its figures

Ruling R65, each a setting of the `[plot]` section, off in both
built-ins: data.file = yes writes the data each of jplot()'s charts
shows to \_figures.xlsx beside the Word file, a sheet per figure
("Figure 1"), for a designer who redraws the charts; vector.file = pdf
or eps writes each figure's picture as a vector file, \_Figure_1.pdf, at
the size it has in the Word file – through cairo_pdf() and cairo_ps(),
which embed the fonts, where R has cairo, else pdf() and postscript(). A
chart drawn in ggplot2 by hand gets a vector file but no data sheet
(ruling R71: the sheet's columns are known only for jstats's own
charts).

## Usage

``` r
.jst_figure_files(items, lay, out_path)
```

## Arguments

- items:

  The document's tables and figures.

- lay:

  Their layout.

- out_path:

  The Word file.

## Value

A list: xlsx (the sheet file written, or NULL), sheets (the figure
numbers it holds) and vector (the files written, named by figure
number).
