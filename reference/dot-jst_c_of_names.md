# Internal helper: the names a c() of names holds

A call `c(Age, "Score")` whose items are all bare names or strings
(ruling R18, Session 356) gives their names; anything else gives NULL.

## Usage

``` r
.jst_c_of_names(e)
```

## Arguments

- e:

  A language object.

## Value

Character, or NULL.
