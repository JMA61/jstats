# Internal helper: the decimal places a variable's data carry

Returns the number of decimal places needed to show every value of a
variable faithfully, capped at `cap` – the precision the DATA carry, as
opposed to the precision of the few values a table happens to print.
jdesc() uses it for Min and Max (Session 328): a variable measured in
whole numbers shows 0 and 75, one measured to a tenth shows 4.8 and
10.0, and each variable keeps its own places when several share a table.
Before, both columns took one precision from the minimums and maximums
in them, so a whole-number variable printed 0.0 and 75.0 beside another
variable's 4.8 and 9.7.

## Usage

``` r
.jst_data_dp(x, cap = 7L)
```

## Arguments

- x:

  A numeric vector (a variable's values; missing values ignored).

- cap:

  Integer. Maximum number of decimal places to report (the digits
  setting in force).

## Value

Integer scalar between 0 and `cap`. Returns 0 for an all-missing vector.

## Details

The work is
[`.jst_col_dp()`](https://jma61.github.io/jstats/reference/dot-jst_col_dp.md)'s,
on the distinct values: a vector of whole numbers returns 0 without
formatting anything, and the scan stops as soon as the cap is reached,
so a full-precision variable with a million distinct values costs one
small batch.
