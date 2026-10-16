# Internal: the date format a text variable's values share

Session 361 (the S222 item, E3). Every distinct value, blank cells set
aside, must match one shape's pattern and parse under its format; for
the day/month shapes each order is tried, and both kept when the values
fit both (no part above 12).

## Usage

``` r
.jst_date_text_format(x)
```

## Arguments

- x:

  A character or factor vector.

## Value

NULL, or a list: `fmt`, one format or two (day/month first); `yy`, TRUE
for a two-digit year; `example`, the first value.
