# Internal helper: format a p-value for a table cell

Exact to `decimals` places with the floor "\<.001" (at 3 places; "\<.01"
at 2), the leading zero dropped as APA writes p; or stars alone; or
both, the stars after the value. NA is a blank cell.

## Usage

``` r
.jst_tbl_p(p, format = "exact", decimals = 3L, stars = c(0.05, 0.01, 0.001))
```

## Arguments

- p:

  Numeric vector.

- format:

  "exact", "stars" or "both".

- decimals:

  Integer.

- stars:

  The thresholds, largest first.
