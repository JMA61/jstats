# Internal helper: format a coefficient, with a near-zero value kept visible

As
[`.jst_tbl_num()`](https://jma61.github.io/jstats/reference/dot-jst_tbl_num.md),
except that a value that rounds to zero at the decimals but is not zero
prints with enough places to show its first digit, as APA's Table 7.17
prints .0002 (Session 402, item 6): a b of -0.00129 at two decimals
prints -0.001, where "0.00" would misreport the coefficient's sign and
size. For b, SE and a confidence limit, which depend on the predictor's
units; a standardized coefficient keeps the decimals.

## Usage

``` r
.jst_tbl_coef(
  x,
  decimals = 2L,
  thousands = "comma",
  leading.zero = TRUE,
  minus = "true"
)
```

## Arguments

- x:

  Numeric vector.

- decimals:

  Integer; the decimal places.

- thousands:

  "comma" or "none".

- leading.zero:

  Logical; FALSE drops the zero before the point of a value between -1
  and 1 (".23", "-.12").

- minus:

  "true" for the minus sign (U+2212), "hyphen" for the hyphen-minus.
