# Internal helper: build a decimal-places formatter for continuous stats

Returns a function that formats a numeric value to `digits` decimal
places via `sprintf("%.\if{html}{\out{<digits>}}f")`, preserving base
R's half-to-even rounding (the option only changes the number of places,
never the rounding rule). `digits = 0` yields whole numbers with no
trailing decimal point. NA formats to the empty string so it renders as
a blank cell. A value that rounds to zero from below prints unsigned
("0.000", not "-0.000"), the rule the jlm and jlogistic coefficient
formatters and jcorr's r cells already follow.

## Usage

``` r
.jst_make_fmt(digits)
```

## Arguments

- digits:

  Integer number of decimal places (0-7).

## Value

A function of one argument (coerced via as.numeric) returning a
character vector the same length as its input.

## Details

Since Session 326 this is the formatter behind the `digits` argument of
[`.jst_print_table()`](https://jma61.github.io/jstats/reference/dot-jst_print_table.md)
(every column a caller fixes) and behind
[`.jst_fmt_stat()`](https://jma61.github.io/jstats/reference/dot-jst_fmt_stat.md)
(the effect-size result lines).
