# Internal: does each string read as a number?

TRUE for text that is a number as written: digits with an optional sign,
decimal point and exponent ("7", "-2.5", "1e3", ".5"), spaces around it
allowed. "Inf", "NA", "1,000" and "50\\ note and the stray-parts note
(Session 365).

## Usage

``` r
.jst_is_number_text(x)
```

## Arguments

- x:

  Character vector.

## Value

Logical vector; NA and "" are FALSE.
