# Internal helper: look up a single variable's registered intent

Returns the intent record for one variable in a named data frame, or
`NULL` if the variable has no registered intent. Consulted by the
classification resolver (tier 2) and by the registration functions.

## Usage

``` r
.jst_get_intent(data_name, var_name)
```

## Arguments

- data_name:

  Character string giving the data frame name.

- var_name:

  Character string giving the variable name.

## Value

The intent record (a list with at least `kind`), or `NULL`.
