# Internal helper: draw a pie or a donut chart

Ruling R66 (Session 412; final Session 413): one variable as one whole,
its categories with cases the slices, clockwise from 12 o'clock in the
variable's own order – the order jfreq() prints – darkest first; each
slice labelled outside it with its category and, under the style's
values = yes, its percentage; no legend; labels that would collide
pushed apart and joined to their slices by a thin line. A donut's hole
is half the radius, and empty.

## Usage

``` r
.jst_build_pie(data, x_name, donut = FALSE, look = .jst_plot_look_now())
```

## Arguments

- data:

  The frame, the variable a factor or a vector.

- x_name:

  Character(1); the variable.

- donut:

  Logical(1).

- look:

  A look.

## Value

The chart, as a builder returns it
([`.jst_plot_built()`](https://jma61.github.io/jstats/reference/dot-jst_plot_built.md)).
