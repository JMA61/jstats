# Internal helper: remove named variables' registrations of one kind

The `remove = TRUE` half of the four registration verbs, working from
the data frame's NAME alone: the stores are keyed by name, so a
registration can be removed after its data frame is gone
([`.jst_registration_by_name()`](https://jma61.github.io/jstats/reference/dot-jst_registration_by_name.md);
Session 342). "numeric", "count" and "likert" remove a variable's record
from the `.jst_registry` notebook only when it is of that kind; "dummy"
removes its `.jst_dummy` entry.

## Usage

``` r
.jst_remove_registrations(kind, data_name, var_names)
```

## Arguments

- kind:

  One of "numeric", "count", "likert", "dummy".

- data_name:

  Character; the data frame's name.

- var_names:

  Character; the variables named.

## Value

`invisible(NULL)`. Called for its message.
