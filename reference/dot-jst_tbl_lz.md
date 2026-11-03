# Internal helper: whether a number keeps the zero before its point

The style's leading.zero setting, read for one kind of number: yes keeps
the zero on every number; no drops it on a statistic that cannot exceed
1 (p, beta, r, R2 – APA's rule) and keeps it on any other (b, SE, a
mean); never drops it on every number below 1 (".197" for an SE; Session
402, item 5).

## Usage

``` r
.jst_tbl_lz(setting, bounded = FALSE)
```

## Arguments

- setting:

  The leading.zero value.

- bounded:

  Logical; TRUE for a statistic bounded by 1.

## Value

Logical(1).
