# Internal helper: standardize the return value of jplot dispatch methods

Strips `NULL` entries from a list of ggplot objects, then returns the
list invisibly – or, if exactly one plot remains, returns that plot
alone. Used so that
[`jplot()`](https://jma61.github.io/jstats/reference/jplot.md) returns a
sensible value for the single-plot case (suitable for further piping or
printing) without losing flexibility for the multi-plot case.

## Usage

``` r
.jst_return_plots(plots)
```

## Arguments

- plots:

  A list of ggplot objects, possibly containing `NULL` entries.

## Value

Invisibly: `NULL` if all plots are `NULL`; a single ggplot if exactly
one non-`NULL` plot remains; otherwise the trimmed list.
