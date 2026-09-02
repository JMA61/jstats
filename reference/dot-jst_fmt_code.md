# Internal helper: render a numeric code without a trailing decimal

Whole numbers render as integers (`-99`, not `-99.0`); other values fall
through to [`format()`](https://rdrr.io/r/base/format.html). Used by
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)'s
message surface wherever a code value is shown to the user.

## Usage

``` r
.jst_fmt_code(x)
```

## Arguments

- x:

  Numeric scalar.

## Value

Character scalar.
