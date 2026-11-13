# Internal helper: draw the ranked bar of a multiple-response set

Ruling R67 (Session 412): one horizontal bar per option, in the order of
the result's table – most chosen first, or the data frame's order where
the table keeps it – with "None of these" last after a small gap,
whatever its size; each bar's percentage of everyone who answered at its
end (ruling R70: one series, under the style's values = yes); one color;
the value axis titled "Percentage of cases" (ruling R88) and running to
the next ten above the longest bar (the S412 audit's F15); the look's
axes and gridlines, turned for bars that run across.

## Usage

``` r
.jst_build_ranked(rows, look = .jst_plot_look_now())
```

## Arguments

- rows:

  A data frame: label (each bar's), percent, n, and none (TRUE for a
  "None of these" row).

- look:

  A look.

## Value

The chart, as a builder returns it
([`.jst_plot_built()`](https://jma61.github.io/jstats/reference/dot-jst_plot_built.md)).
