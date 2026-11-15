# Internal helper: the variables a range in a one-variable slot names

For the slots that take ONE variable, and jrelabel()'s variable slot
(Session 430, the (S429) range item): a range `A:B` read against the
data frame as every variable list reads it since ruling R90 – every
variable from its first end to its last, through
[`.jst_resolve_varrange()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_varrange.md),
so an end that is not a variable takes the not-found sentence and ends
the wrong way round take the stop that turns them. A range inside
[`c()`](https://rdrr.io/r/base/c.html) is not read so, as ruling R90
keeps it on the not-found stop in every variable list; nor is a range of
numbers (`1:3`). Anything else, or no data frame, gives NULL, and the
caller reads the slot as before.

## Usage

``` r
.jst_slot_range_names(ex, data, data_name = NULL, default_used = FALSE)
```

## Arguments

- ex:

  The slot as typed.

- data:

  The data frame, or NULL.

- data_name, default_used:

  As
  [`.jst_resolve_varrange()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_varrange.md).

## Value

Character, the names in the data frame's order, or NULL.
