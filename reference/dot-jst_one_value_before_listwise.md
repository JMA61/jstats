# Internal helper: does a variable hold one value before listwise deletion?

A filter is named as the cause of a variable's one value only when the
filtered data already hold one value of it; when listwise deletion on
another variable took the rest, the filter did not. A term that is not a
column (a computed term) is taken as yes.

## Usage

``` r
.jst_one_value_before_listwise(data, v)
```

## Arguments

- data:

  The filtered data, before listwise deletion.

- v:

  Character(1); the variable or term.

## Value

Logical(1).
