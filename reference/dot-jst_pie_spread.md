# Internal helper: a pie's labels kept apart

The labels on one side of a pie, top to bottom, each at least its own
height from the next, and each as near the height its slice asks for as
that allows: an isotonic fit of the heights asked for (ruling R66:
"labels that would collide pushed apart").

## Usage

``` r
.jst_pie_spread(y, h, lo = -1.2, hi = 1.2)
```

## Arguments

- y:

  Numeric; the heights asked for.

- h:

  Numeric; each label's height.

- lo, hi:

  Numeric(1); the lowest and highest a label may sit.

## Value

Numeric; the heights given, in the order of y.
