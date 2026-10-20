# Internal helper: the line that assigns jrelabel()'s variable to its column

`d$Q1 <- jrelabel(d, Q1, <rest>)` (Session 378): on a place,
`lst$d$Q1 <- jrelabel(lst$d, Q1, <rest>)`; on an expression, the naming
line first; under the
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default,
the data frame left out of the call. A name R cannot read bare is
backticked after the `$`.

## Usage

``` r
.jst_relabel_assign_line(
  data_sub,
  data_kind,
  default_used,
  data_name,
  var_name,
  rest
)
```

## Arguments

- data_sub:

  The data argument as typed.

- data_kind:

  "name", "place" or "expression".

- default_used:

  Logical.

- data_name:

  Character(1); the data frame's name.

- var_name:

  Character(1).

- rest:

  Character(1); the arguments after the variable.

## Value

Character(1), the indented line(s).
