# Internal helper: the probability note the stars key makes

Generated from the thresholds, so it can never disagree with the cells:
"\*p \< .05. \*\*p \< .01. \*\*\*p \< .001." The p is set in italics by
the Word writer, which reads the marker.

## Usage

``` r
.jst_tbl_stars_legend(stars = c(0.05, 0.01, 0.001), leading.zero = "no")
```

## Arguments

- stars:

  The thresholds.

- leading.zero:

  The style's leading.zero setting: p is a statistic bounded by 1, so
  its zero is kept only under "yes", as in the cells (Session 409: until
  then the legend dropped it under every setting, "\*p \< .05" beneath
  cells reading 0.003).

## Value

Character(1).
