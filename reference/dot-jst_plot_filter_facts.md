# Internal helper: the filters a chart was drawn under, for its figure's note

A figure's general note names a filter as a table's does (ruling R63: "a
filter sentence"): the stored jsubset() filter and the call's subset =,
kept as the results keep them, with a slice of no rows of the data frame
holding the variables the conditions name, so the note can put them into
words with their labels without the chart carrying the data frame.

## Usage

``` r
.jst_plot_filter_facts(si)
```

## Arguments

- si:

  The pipeline's counts, or a result's sample_info.

## Value

NULL when no filter ran, else a list as sample_info holds it.
