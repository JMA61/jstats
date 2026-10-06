# Internal helper: the assignment lines of an assign-or-lose reminder

The code lines under the reminders of
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md),
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md),
[`jsum()`](https://jma61.github.io/jstats/reference/jsum.md) and
[`javg()`](https://jma61.github.io/jstats/reference/javg.md), each of
which returns a new variable's values and changes nothing. A name or a
place gets the one pattern line it always had. An expression gets two:
it is assigned to `mydata`, and the pattern line is written on `mydata`,
because `mk()$<name> <- jsum(...)` is not R (Session 343).

## Usage

``` r
.jst_assign_lines(fn_name, data_name, data_kind, typed)
```

## Arguments

- fn_name:

  Character(1); the function the lines call.

- data_name:

  Character(1); the data frame as the line names it.

- data_kind:

  What the call gave as its data, as
  [`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)
  reads it.

- typed:

  Character(1); the data argument as typed.

## Value

Character(1): one line or two, each ending in a newline.
