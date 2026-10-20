# Internal helper: the names of jrelabel()'s variable slot

A bare or quoted name, or a [`c()`](https://rdrr.io/r/base/c.html) of
them (ruling R18), as character. With `several_only = TRUE`,
`character(0)` unless the slot is a
[`c()`](https://rdrr.io/r/base/c.html) of two or more – the list form
(Session 378); `c(Q1)` is one variable. Anything else gives
`character(0)`.

## Usage

``` r
.jst_relabel_slot_names(sub, several_only = FALSE)
```

## Arguments

- sub:

  The slot as typed, or NULL.

- several_only:

  Logical.

## Value

Character.
