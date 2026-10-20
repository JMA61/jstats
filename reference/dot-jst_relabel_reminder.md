# Internal helper: jrelabel()'s assign-or-lose reminder

Printed after a one-variable call without `modify = TRUE`, at the
standard and full output levels (Session 378; Jeff's okay), as
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md),
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md),
[`jsum()`](https://jma61.github.io/jstats/reference/jsum.md) and
[`javg()`](https://jma61.github.io/jstats/reference/javg.md) print
theirs. A function cannot see whether its result is assigned, so it
prints on every such call and is worded to be true either way. On a name
(or the juse() default): the assignment line and the `modify = TRUE`
line; on a place, the assignment alone (`modify = TRUE` needs a name);
on an expression, the naming line first. The call's own arguments are
elided to "..." (voice Rule K).

## Usage

``` r
.jst_relabel_reminder(data_sub, data_kind, data_name, var_name)
```

## Arguments

- data_sub:

  The data argument as typed.

- data_kind:

  "name", "place" or "expression".

- data_name:

  Character(1).

- var_name:

  Character(1).

## Value

Character(1).
