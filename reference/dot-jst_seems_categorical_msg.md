# Internal helper: the "seems categorical" warning of jlm() and jlogistic()

A predictor that looks categorical and entered the model as a number
gets a warning with the two ways to treat it as categorical, each as
lines to run: register it with
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) and run
the model again, or name it in `categorical =` for this call.

## Usage

``` r
.jst_seems_categorical_msg(
  fn,
  v,
  formula,
  data_name,
  data_kind,
  default_used,
  categorical = NULL
)
```

## Arguments

- fn:

  Character(1); `"jlm"` or `"jlogistic"`.

- v:

  Character; the predictor's name, or the names of several.

- formula:

  The formula as the call gave it.

- data_name:

  Character(1); the data frame as the call named it, or the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default's
  name.

- data_kind:

  What the call gave as its data, as
  [`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)
  reads it.

- default_used:

  Logical; the call gave no data.

- categorical:

  The call's own `categorical =`, kept in the second route's line.

## Value

Character(1); the warning's text.

## Details

Until Session 346 the rerun lines were built from
`.jst_unbacktick(deparse(formula))` on the REWRITTEN formula.
[`deparse()`](https://rdrr.io/r/base/deparse.html) returns one string
for each 60 characters, so any longer formula printed cut off, with a
stray closing parenthesis; the backticks a name such as
`` `W2-W24 (binary)` `` needs were stripped with those of the computed
terms; a variable already registered with
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
appeared as its dummy columns; and a call that named its data frame was
offered `jlm(y ~ x)`, which runs only with a
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
(the S345 item). The lines are now built from the formula as typed, in
one piece, with the data the call named. The second call sits on a line
of its own: after "Or: " it was wrapped as prose, and a break could land
inside a backticked name.

An expression given as the data (`jlm(y ~ g, mk())`) cannot be
registered on, so the first route names it first (`mydata <- mk()`), as
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)'s
reminder does since v0.9.217. Arguments of the call other than the
formula and the data are not repeated.

Several predictors that seem categorical get ONE warning (Session 347):
each had a warning of its own, with its own
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) line
and the same refit line repeated. Now the names are joined in the first
line, one
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) call
takes them all, and `categorical =` lists them.
