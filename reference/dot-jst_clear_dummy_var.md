# Internal helper: clear one variable's dummy registration

Removes the `.jst_dummy` entry for a single variable in a named data
frame, used to enforce mutual exclusion when the variable is
re-registered as numeric or count. Returns TRUE when an entry was
actually removed (so the caller can report the reclassification).

## Usage

``` r
.jst_clear_dummy_var(data_name, var_name)
```

## Arguments

- data_name:

  Character data-frame name.

- var_name:

  Character variable name.

## Value

Logical, invisibly: TRUE if a dummy entry was cleared.
