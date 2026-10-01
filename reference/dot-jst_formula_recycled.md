# Internal helper: find a workspace vector that a computed term recycles

A name inside a computed term that is not a variable resolves in the
formula's environment (the S322 constant rule), and nothing checked its
length: with `v <- c(1, 2, 3)`, `I(Stress * v)` fitted on R's recycled
`1, 2, 3, 1, 2, 3, ...` behind its "longer object length" warning – with
no warning at all when the row count divides by the length – and
[`lm()`](https://rdrr.io/r/stats/lm.html) does the same (Session 324,
the S323 item). This walks each computed term of the formula, both
sides, and returns the first operand of an element-wise operation –
arithmetic, a comparison, `&`, `|` or `!`, or an argument of
[`ifelse()`](https://rdrr.io/r/base/ifelse.html),
[`pmin()`](https://rdrr.io/r/base/Extremes.html) or
[`pmax()`](https://rdrr.io/r/base/Extremes.html) – that reads no
variable of the data and holds more than one value but not one per row
of `data`. A single value passes (the constant rule), and so does
anything not combined value by value: a set used with `%in%`, a lookup
indexed by a variable (`w[Group]`), a summary (`max(w)`).

## Usage

``` r
.jst_formula_recycled(formula, data, enclos)
```

## Arguments

- formula:

  The analysis formula as typed.

- data:

  The analysis data frame, after the pipeline's filters.

- enclos:

  The environment the formula's other names resolve in.

## Value

NULL when there is none; otherwise a list of `term` (the computed term)
and `operand` (the operand as written), both language objects, and `n`
(the operand's number of values).

## Details

An operand is looked up, never run: a name, an element reached with `$`,
`[[` or `@`, and [`c()`](https://rdrr.io/r/base/c.html) or `:` over
names and numbers are evaluated, because doing so has no side effect;
any other call (`rnorm(70)`, `rev(w)`) is left to the resolver's own
checks, so the check never draws a random number or runs the user's code
twice.
