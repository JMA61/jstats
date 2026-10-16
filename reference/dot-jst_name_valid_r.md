# Internal: can R read each name bare?

TRUE for a name R code can use as it is: syntactic (make.names() leaves
it unchanged), not a reserved word, not "..." or "..1". Empty and NA are
FALSE. Duplicates are the caller's test.

## Usage

``` r
.jst_name_valid_r(x)
```

## Arguments

- x:

  Character vector of names.

## Value

Logical vector of the same length.
