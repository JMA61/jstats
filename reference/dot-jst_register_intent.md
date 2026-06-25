# Internal helper: shared registration engine for jnumeric() / jcount()

Validates the requested variables, then either removes their
registrations of the given kind (`remove = TRUE`) or writes them,
enforcing mutual exclusion: writing a record replaces any prior intent
record for that variable (one record per variable in `.jst_registry`)
and clears any `.jst_dummy` registration for it. Any reclassification (a
variable that previously carried a different intent or a dummy
registration) is reported. A standard-tier reminder notes that
registrations are session-only and how to persist them.

## Usage

``` r
.jst_register_intent(kind, data, data_name, default_used, var_names, remove)
```

## Arguments

- kind:

  One of "numeric", "count".

- data:

  The resolved data frame.

- data_name:

  Character data-frame name (the registry key).

- default_used:

  Logical; whether the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  frame was used.

- var_names:

  Character vector of variable names to register.

- remove:

  Logical; if TRUE, remove rather than write.

## Value

`invisible(NULL)`.
