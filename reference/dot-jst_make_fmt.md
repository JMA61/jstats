# Internal helper: build a decimal-places formatter for continuous stats

Returns a function that formats a numeric value to `digits` decimal
places via `sprintf("%.\if{html}{\out{<digits>}}f")`, preserving base
R's half-to-even rounding (the option only changes the number of places,
never the rounding rule). `digits = 0` yields whole numbers with no
trailing decimal point. NA formats to the empty string so it renders as
a blank cell.

## Usage

``` r
.jst_make_fmt(digits)
```

## Arguments

- digits:

  Integer number of decimal places (0-7).

## Value

A function of one argument (coerced via as.numeric) returning a
character string.
