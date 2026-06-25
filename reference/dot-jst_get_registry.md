# Internal helper: get the intent registry for a named data frame

Looks up the analysis-role intent records stored under the
`.jst_registry` option for a specific data frame name. This is the
general intent notebook for jnumeric()/jcount() registrations; it
follows the same session-option, frame-keyed model as `.jst_dummy` but
is a separate store, so the existing dummy consumers are unaffected.
Records are a named list keyed by variable name (lookup and replace are
the dominant operations), each a list with at least `kind` (one of
"numeric" or "count"; the slot is general enough for later facets such
as centering).

## Usage

``` r
.jst_get_registry(data_name)
```

## Arguments

- data_name:

  Character string giving the data frame name to look up.

## Value

The stored intent records (a named list), or `NULL` if none.
