# Internal helper: find a workspace vector that an expression recycles

The walker behind
[`.jst_formula_recycled()`](https://jma61.github.io/jstats/reference/dot-jst_formula_recycled.md)
(a formula's computed terms, Session 324) and
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md)
(a filter condition, Session 330). It walks each expression in `terms`
and returns the first operand of an element-wise operation – arithmetic,
a comparison, `&`, `|` or `!`, or an argument of
[`ifelse()`](https://rdrr.io/r/base/ifelse.html),
[`pmin()`](https://rdrr.io/r/base/Extremes.html) or
[`pmax()`](https://rdrr.io/r/base/Extremes.html) – that reads no
variable of the data and holds more than one value but not one per row
of `data`. A single value passes (the constant rule), and so does
anything not combined value by value: a set used with `%in%`, a lookup
indexed by a variable (`w[Group]`), a summary (`max(w)`).

## Usage

``` r
.jst_recycled_operand(terms, data, enclos)
```

## Arguments

- terms:

  A list of language objects: a formula's variables, or a single filter
  condition. Anything that is not a call is skipped.

- data:

  The data frame the expressions are evaluated against.

- enclos:

  The environment the expressions' other names resolve in.

## Value

NULL when there is none; otherwise a list of `term` (the expression
holding it) and `operand` (the operand as written), both language
objects, and `n` (the operand's number of values).

## Details

An operand is looked up, never run: a name, an element reached with `$`,
`[[` or `@`, and [`c()`](https://rdrr.io/r/base/c.html) or `:` over
names and numbers are evaluated, because doing so has no side effect;
any other call (`rnorm(70)`, `rev(w)`) is left to the caller's own
checks, so the check never draws a random number or runs the user's code
twice.
