# Internal helper: a value axis that starts at zero

Bars and a histogram's bins stand on the axis line (ruling R64: "bars
from zero"), with room above the tallest for its value. An axis of
counts is marked in whole numbers only (Session 415): ggplot2's own
breaks put 2.5 and 7.5 on a histogram's Count axis.

## Usage

``` r
.jst_plot_zero_y(count = FALSE)
```

## Arguments

- count:

  TRUE for an axis of counts.
