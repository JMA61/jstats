# Internal: jsum() and javg()'s min.valid, checked

NULL means every variable must be present; otherwise a positive whole
number no larger than the number of variables (Session 383 gave the two
copies one home).

## Usage

``` r
.jst_min_valid_threshold(min.valid, n_vars, fn)
```

## Arguments

- min.valid:

  The argument as given.

- n_vars:

  Integer. The number of variables.

- fn:

  Character(1). "jsum" or "javg", for the argument stop.

## Value

Integer(1): the threshold.
