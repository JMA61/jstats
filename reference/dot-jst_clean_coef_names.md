# Internal helper: clean up factor coefficient names for output

By default, R concatenates factor variable names with level names when
producing regression coefficient labels (e.g. "GenderRFemale"). This
helper inserts a separator between the variable name and level name for
readability (e.g. "GenderR-Female"). Only applies to factor IVs; numeric
dummy columns created by jdummy() are left unchanged since they are
already named clearly.

## Usage

``` r
.jst_clean_coef_names(coef_names, data, iv_names, sep = "-")
```

## Arguments

- coef_names:

  Character vector of coefficient names from a fitted model.

- data:

  Data frame used to fit the model (post-conversion).

- iv_names:

  Character vector of IV names from the model formula.

- sep:

  Character. Separator to insert. Default is "-".

## Value

Character vector of the same length as coef_names, with factor
coefficient names separated.
