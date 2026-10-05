# Internal helper: several conditions as one, joined with the and operator

The text of the joined call the
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) stops
offer. A condition whose own top-level operator is `|` is parenthesized,
since `&` binds more tightly; a single condition is returned as typed.

## Usage

``` r
.jst_join_conditions(conds)
```

## Arguments

- conds:

  A list of unevaluated conditions, one or more.

## Value

Character(1).
