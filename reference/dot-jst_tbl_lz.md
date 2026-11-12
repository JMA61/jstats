# Internal helper: whether a number keeps the zero before its point

The style's leading.zero setting, read for one kind of number: under yes
every number keeps the zero; under no a statistic that cannot exceed 1
(p, beta, r, R2 – APA's rule) loses it and any other (b, SE, a mean)
keeps it; under never no number below 1 has one (".197" for an SE;
Session 402, item 5).

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
