# Internal helper: check a model formula's names as lm() reads them

The front door of jt(), jaov(), jlm() and jlogistic() (Session 323; the
S322 rulings), replacing `all.vars(formula)` at their
[`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md)
site. A name inside a computed term resolves the way
[`lm()`](https://rdrr.io/r/stats/lm.html) resolves it: in the data
first, then in the formula's environment (`environment(formula)`, with
[`model.frame()`](https://rdrr.io/r/stats/model.frame.html)'s
[`parent.frame()`](https://rdrr.io/r/base/sys.parent.html) fallback –
the transform resolver's own enclosure), whatever the object's shape: a
single value (`I(x > cutoff)`), a set of codes
(`I(Education %in% codes)`), a power (`I(x^k)`). Such a name is a
constant; the resolver's one-value-per-case checks judge what the term
gives. A BARE name stays a data variable, the one place jstats stays
narrower than [`lm()`](https://rdrr.io/r/stats/lm.html), which needs no
data frame. A name found in neither place goes on to
[`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md),
so a typo keeps the not-found stop. Two refusals come first: a power
[`terms()`](https://rdrr.io/r/stats/terms.html) cannot read (`y ~ x^k`;
[`.jst_formula_bad_power()`](https://jma61.github.io/jstats/reference/dot-jst_formula_bad_power.md)),
and a data frame named inside a term
([`.jst_check_formula_frames()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_frames.md)).
A formula [`terms()`](https://rdrr.io/r/stats/terms.html) cannot process
for any other reason falls back to
[`all.vars()`](https://rdrr.io/r/base/allnames.html), unchanged.

## Usage

``` r
.jst_check_formula_vars(formula, data, data_name, default_used = FALSE)
```

## Arguments

- formula:

  The analysis formula as typed.

- data:

  The analysis data frame (the post-pipeline copy).

- data_name:

  Character; the data frame's name, for messages.

- default_used:

  Logical; passed to
  [`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md).

## Value

The data variables the formula names, constants left out, in order of
first appearance – the list the Case Processing Summary receives as
`analysis_vars`. Stops instead when a name is found nowhere, a data
frame is named inside a term, or a power is refused.
