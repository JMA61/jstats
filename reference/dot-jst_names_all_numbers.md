# Internal: are the names read from a file all numbers?

The S362 import audit's item 14: a CSV file or a sheet with no names row
loses its first case to the names, which are then numbers. TRUE when
every name that is not empty reads as a number and at least one does. An
empty name does not count against it: a first case with a missing value
has one (1,,3).

## Usage

``` r
.jst_names_all_numbers(nm)
```

## Arguments

- nm:

  Character vector: the names as read.

## Value

TRUE or FALSE.
