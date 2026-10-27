# Internal helper: a formula function given the data-first form

jt(), jaov(), jcrosstab(), jlm() and jlogistic() take a formula first.
Called as the data-first functions are – `jt(d, Age)`,
`jlm(d, Income, Age, Education)`, or under a
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
`jt(Age, Volunteer)` – each stopped in R's own words, with no prefix:
"object 'Age' not found", the second name read as the data and the third
as `paired =` or `subset =`, each evaluated before any check saw the
call (Fix Slate 31, Session 397; the (S395) item).

## Usage

``` r
.jst_formula_first_stop(cl, fn, example, envir)
```

## Arguments

- cl:

  The call as typed
  ([`sys.call()`](https://rdrr.io/r/base/sys.parent.html) of the
  exported function).

- fn:

  The user-facing function name.

- example:

  The function's generic formula, for the stop it has always given
  (`"Outcome ~ Group"`).

- envir:

  The caller's calling frame, where the names typed are looked up.

## Value

`invisible(NULL)`, or stops.

## Details

Run first in each function, before any input is evaluated, on the call
as typed. It acts only on a call with no formula in it: no argument is a
`~` expression, the first input is not a formula, not a quoted formula,
and no later name holds one (the swapped order, `jt(d, f)`, keeps its
own stop). Then:

- the first input is a data frame: the names after it are the variables,
  and the data frame stays after the formula offered;

- a [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  is set and the first input is a name found nowhere or a variable of
  the default: every name is read as a variable of the default, and the
  call offered names no data frame;

- otherwise the formula stop the caller has always given, in the same
  words.

A formula is offered when the names fill it – two for jt(), jaov() and
jcrosstab(), two or more for jlm() and jlogistic() – each a variable of
the data frame: the first as the outcome (the row variable in
jcrosstab()), in the order typed, which the line above it says; the
call's other named inputs kept. Otherwise the line says what the formula
names, and the function's own example on community follows
(`.jst_formula_examples`).
