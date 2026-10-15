# Internal helper: the one variable a single-variable slot names

[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md),
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md) and
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md) take
ONE variable, and read it with `deparse(substitute())`, so a name in
quotes was refused as not found: `'"Gender" was not found'`, where the
thirteen other slots took it (ruling R18, Session 355; built Session
356). This reads the slot as the lists do: a bare name, a quoted name,
or a [`c()`](https://rdrr.io/r/base/c.html) of one; a
[`c()`](https://rdrr.io/r/base/c.html) of several stops, naming them,
since the function takes one. Anything else is deparsed as before and
meets the not-found check.

## Usage

``` r
.jst_one_var_name(sub, fn, slot = "after the data frame")
```

## Arguments

- sub:

  The slot as typed
  ([`substitute()`](https://rdrr.io/r/base/substitute.html)), or a
  quosure.

- fn:

  Character(1); the user-facing function's name.

- slot:

  Character(1); how the sentence names the slot: "after the data frame"
  (the default), or "by =".

## Value

Character(1), the name.
