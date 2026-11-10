# Internal helper: a chart's colors for n series

Under greys (both built-ins; ruling R64): 595959 for one series, 404040
and A6A6A6 for two, and from 404040 in even steps for more – to BFBFBF
for three or four, to D9D9D9 for five or more, so the lightest stays
visible on white. Under a list of colors, the first n in order; past the
list's length, colors between them.

## Usage

``` r
.jst_plot_colours(look, n)
```

## Arguments

- look:

  A look.

- n:

  Integer(1), the series.

## Value

Character, n colors as "#RRGGBB".
