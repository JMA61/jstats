# Internal helper: detect common SPSS-style syntax mistakes in a filter expression and show the corrected form

Called on the PARSED filter expression from two places:
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) at
set time (`origin = "set"`, before the dry run) and
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
at apply time for a per-call `subset =` (`origin = "call"`, before
[`.jst_apply_mask()`](https://jma61.github.io/jstats/reference/dot-jst_apply_mask.md);
Session 290 – before that the per-call route had no syntax check at
all). Two branches:

- the SPSS keywords `AND` / `OR` / `NOT` / `XOR` used as identifiers
  where `&` / `|` / `!` / [`xor()`](https://rdrr.io/r/base/Logic.html)
  were meant. Matching is case-insensitive (SPSS is), but the real
  [`xor()`](https://rdrr.io/r/base/Logic.html) is exempt (Session 290;
  it used to be refused, with a message recommending itself).

- an operator `=` where `==` was meant. Each error shows the corrected
  call, built from the input by walking the expression: a keyword call
  head becomes its R operator (the operand of `NOT` is parenthesized so
  the result reads `!(Age < 40)`), an `=` call becomes `==`, and every
  other node – named arguments included – is left as is. When a keyword
  is present but not as a call head, so nothing can be rewritten, a
  one-line generic example of the operator stands in. The lead and the
  fix line follow `origin`: `NOT(Age < 40)` ... `jsubset(!(Age < 40))`
  at set time, `subset = NOT(Age < 40)` ... `subset = !(Age < 40)` per
  call.

## Usage

``` r
.jst_check_filter_syntax(raw_expr, expr_str, origin = c("set", "call"))
```

## Arguments

- raw_expr:

  The unevaluated expression (a language object).

- expr_str:

  The deparsed expression string (for display in errors).

- origin:

  `"set"`
  ([`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md))
  or `"call"` (a per-call `subset =`); chooses the lead and the fix-line
  form.

## Details

Inspects the PARSED expression, so it can only see what R's parser let
through: `Condition == 3 AND SoughtHelp == 1` and a top-level
`Gender = 1` never reach it (the parser rejects the first; the second
becomes a named argument, which
[`.jst_check_named_variables()`](https://jma61.github.io/jstats/reference/dot-jst_check_named_variables.md)
catches). The `=` branch therefore fires only on an operator `=` that R
accepted inside parentheses or braces, `(Gender = 1) & (Age < 40)`,
which without the check evaluates as `1 & (Age < 40)` and silently drops
the Gender test – on the per-call route, before Session 290, that is
exactly what happened.

A bare variable name as the whole expression (`jsubset(Gender)`) is no
longer refused here (Session 290, the bare-name branch removed on both
routes): the set-time dry run and the apply-time shape check judge it by
what it produces, so a genuine TRUE/FALSE column passes and a numeric
one gets the shape check's bare-name error ("Gender on its own is a
variable name, which does not select rows in R", with `Gender == 1` as
the fix). The T / F special case that branch carried went with it.
