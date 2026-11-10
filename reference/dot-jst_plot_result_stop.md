# Internal: the stop for a result jplot() does not draw

A jdesc(), jfreq(), jalpha() or jmulti() result. Named as the house
voice names a result – "a jdesc() result", as jsave() says it, never the
class (Session 415; until then "Plotting jst_desc result objects is not
supported.") – and, given by its name, by that name (Rule AD). A
jalpha() or jmulti() result went on to jplot.default(), which read it as
a variable name and said it was not a data frame (Session 415; found in
build 1).

## Usage

``` r
.jst_plot_result_stop(x, x_sub, ...)
```

## Arguments

- x:

  The result.

- x_sub:

  The result as typed.

- ...:

  The lines after the first: what jplot() takes, and an example.

## Value

Does not return; stops.
