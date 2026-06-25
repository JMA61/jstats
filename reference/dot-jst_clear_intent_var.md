# Internal helper: clear one variable's intent-registry record

Removes the `.jst_registry` record for a single variable in a named data
frame. Used by
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) to
enforce mutual exclusion (a variable that becomes a dummy drops any
numeric/count registration).

## Usage

``` r
.jst_clear_intent_var(data_name, var_name)
```

## Arguments

- data_name:

  Character data-frame name.

- var_name:

  Character variable name.

## Value

The kind that was cleared (character), or NULL if none, invisibly.
