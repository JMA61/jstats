# Internal helper: c() of names in a variable list

Ruling R18 (Session 355; built Session 356): a variable list takes a
[`c()`](https://rdrr.io/r/base/c.html) of names, bare or quoted –
`jdesc(d, c(Age, Score))`, `jdesc(d, c("Age", "Score"))` – as the
tidyverse does, where it read "c(Age, Score) was not found". Each item
becomes a variable of its own, in place, in the
[`c()`](https://rdrr.io/r/base/c.html)'s environment; a quoted item
stays the string it was, which every list already reads as a name. Only
a [`c()`](https://rdrr.io/r/base/c.html) whose items are all names or
strings is opened: a range (`Age:Score`), a helper, or an item computed
inside the [`c()`](https://rdrr.io/r/base/c.html) keeps the not-found
stop, as decided. A named item (a misspelled argument, a condition) is
left to
[`.jst_check_named_variables()`](https://jma61.github.io/jstats/reference/dot-jst_check_named_variables.md).

## Usage

``` r
.jst_expand_vars(quos)
```

## Arguments

- quos:

  The captured variable list, after any
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) prepend.

## Value

The list with each such [`c()`](https://rdrr.io/r/base/c.html) opened,
class kept.
