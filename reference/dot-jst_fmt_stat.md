# Internal helper: format one statistic for a result line

Formats a single statistic printed on a line of its own rather than in a
table – jaov's "Eta-squared:" line and jt's "Cohen's d:" line – to
exactly `digits` decimal places, trailing zeros kept (0.100, not 0.1).
The value is rounded with [`round()`](https://rdrr.io/r/base/Round.html)
first, so the number shown is the one those lines showed before Session
326, now padded. A value that rounds to zero from below prints unsigned.
A non-finite value (NaN from a zero total sum of squares, say) prints as
R prints it, never as a blank.

## Usage

``` r
.jst_fmt_stat(x, digits)
```

## Arguments

- x:

  A single numeric value.

- digits:

  Integer number of decimal places (0-7).

## Value

A character string.
