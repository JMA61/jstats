# Internal helper: coerce a POSIXlt vector to atomic POSIXct

POSIXlt is list-backed (nine parallel components), which makes
[`table()`](https://rdrr.io/r/base/table.html),
[`unique()`](https://rdrr.io/r/base/unique.html), and
[`stats::complete.cases()`](https://rdrr.io/r/stats/complete.cases.html)
either abort or misbehave. Returns the equivalent atomic POSIXct (same
instants); non-POSIXlt input is returned unchanged. Mirrors the POSIXlt
-\> POSIXct remedy jsave recommends for unstorable column types.

## Usage

``` r
.jst_posixlt_to_posixct(x)
```

## Arguments

- x:

  A variable / data-frame column.

## Value

`x` as POSIXct if it was POSIXlt, otherwise `x` unchanged.
