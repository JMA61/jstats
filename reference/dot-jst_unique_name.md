# Internal: make a new name unique among names already taken

Compared ignoring case, since SPSS and SAS fold case and a new name
costs nothing to keep clear of both: a taken name gets \_2, \_3 and so
on, the base shortened to leave room for the suffix.

## Usage

``` r
.jst_unique_name(s, taken, max_chars = 32L, max_bytes = 64L)
```

## Arguments

- s:

  Character(1).

- taken:

  Character vector.

- max_chars, max_bytes:

  Length budget.

## Value

Character(1).
