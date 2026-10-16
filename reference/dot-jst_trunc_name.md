# Internal: shorten a name to a character and a byte budget

Cuts at a character, never inside one, then drops the underscores the
cut leaves at the end.

## Usage

``` r
.jst_trunc_name(s, max_chars = 32L, max_bytes = 64L)
```

## Arguments

- s:

  Character(1).

- max_chars, max_bytes:

  The budgets.

## Value

Character(1).
