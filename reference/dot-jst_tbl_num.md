# Internal helper: format a number for a table cell

Internal helper: format a number for a table cell

## Usage

``` r
.jst_tbl_num(
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

## Value

Character vector; NA is "".
