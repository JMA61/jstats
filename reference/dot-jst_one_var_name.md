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
.jst_one_var_name(
  sub,
  fn,
  slot = "after the data frame",
  data = NULL,
  data_name = NULL,
  default_used = FALSE
)
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

- data:

  The data frame, or NULL; a range is read against it.

- data_name, default_used:

  For a range's not-found sentence, as
  [`.jst_resolve_varrange()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_varrange.md)
  takes them.

## Value

Character(1), the name.

## Details

A range of variables, `A:B` (Session 430, the (S429) range item), is
read as every variable list reads one since ruling R90, when the caller
passes its data frame: every variable from A to B in the data frame's
order, the range's own stops kept (an end not found, the ends the wrong
way round). A range that names one variable gives its name; one that
names several gets the slot's one-variable stop, which says what the
range names. A range inside [`c()`](https://rdrr.io/r/base/c.html), and
a range with no data frame given, are deparsed as before and meet the
not-found check, as ruling R90 keeps a range inside
[`c()`](https://rdrr.io/r/base/c.html) in every variable list.
