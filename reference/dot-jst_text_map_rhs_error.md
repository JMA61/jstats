# Internal helper: text-map right-hand-side error text

Shared by the two places
[`.jst_parse_text_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_text_map.md)
rejects a target, so the wording stays in one place. Detects the common
commas-instead-of-semicolons slip first.

## Usage

``` r
.jst_text_map_rhs_error(rhs, rule)
```

## Arguments

- rhs:

  Character. The offending right-hand side.

- rule:

  Character. The whole rule.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
