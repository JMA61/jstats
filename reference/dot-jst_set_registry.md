# Internal helper: set the intent registry for a named data frame

Stores analysis-role intent records under the `.jst_registry` option,
keyed by data frame name. Used internally by the registration functions
(jnumeric, jcount).

## Usage

``` r
.jst_set_registry(data_name, settings)
```

## Arguments

- data_name:

  Character string giving the data frame name.

- settings:

  A named list of intent records (keyed by variable name), or `NULL` to
  clear the registry for this frame.

## Value

`invisible(NULL)`. Called for its side effect on the `.jst_registry`
option.
