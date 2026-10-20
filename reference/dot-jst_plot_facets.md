# Internal helper: one panel per group (facet =)

Adds
[`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
on the builder's `facet` column when a facet variable was given
(Capability Slate C3, Session 378), and returns the plot as it is
otherwise. The column is the facet variable made a factor, its value
labels the panel titles.

## Usage

``` r
.jst_plot_facets(p, facet_name)
```

## Arguments

- p:

  The ggplot.

- facet_name:

  Character(1) or NULL.

## Value

The ggplot.
