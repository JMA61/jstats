# Internal helper: the sentence saying what an argument of names takes

Voice Rule A's choice form for an argument that takes one or more names
from a fixed set, with any values it takes besides them first:
"`diagnostics` must be TRUE, FALSE, or one or more of "vif", "qq", and
"cooks"." Built here once (Session 376), for the diagnostics stop
(.jst_check_diagnostics(), whose sentence it was) and jplot()'s `which`
(.jst_resolve_which()); any argument of names whose value is not one of
its set states its set with it. A set of one name reads "..., or
"heatmap"."

## Usage

``` r
.jst_takes_names(arg, valid, lead = NULL)
```

## Arguments

- arg:

  Character(1); the argument's name, backticked in the sentence.

- valid:

  Character; the names it takes, each put in double quotes.

- lead:

  Character; values it takes besides the names, as they are to print
  (`TRUE`, or `"\"core\""` with its quotes).

## Value

Character(1), ending in a full stop.
