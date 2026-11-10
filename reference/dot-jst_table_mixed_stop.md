# Internal helper: the stop for saved results beside built tables or charts

A saved result is made a table in a call of its own, then given with the
built tables and charts (the S412 audit's F2, Session 413: a chart
counts as built, so list(m, p) stops as list(m, t) does). Where the list
was typed in the call, the lines that make each result's table and write
everything to one file are given, as ruling R56's stop gives them.

## Usage

``` r
.jst_table_mixed_stop(results, built, is_fig, x_sub, env)
```

## Arguments

- results:

  The list.

- built:

  Logical, one per element: a built table, a figure or a chart.

- is_fig:

  Logical, one per element: a figure or a chart.

- x_sub:

  The call's first argument as typed.

- env:

  The caller's environment.
