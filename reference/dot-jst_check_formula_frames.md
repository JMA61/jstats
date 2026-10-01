# Internal helper: refuse a data frame named inside a formula term

The one exception to [`lm()`](https://rdrr.io/r/stats/lm.html) parity
(the S322 ruling, built in Session 323).
[`lm()`](https://rdrr.io/r/stats/lm.html) accepts
`d$Flourishing ~ d$Income`; jstats does not, because the transform
resolver evaluates each term with the analysis copy as data and the
formula's environment as enclosure, so `d$Income` would be read from the
user's RAW frame – declared missing values back as numbers, stored
filters bypassed. A list or vector of constants (`params$cutoff`) is not
a data frame and passes. Each call term is scanned with
[`.jst_frame_refs()`](https://jma61.github.io/jstats/reference/dot-jst_frame_refs.md);
a bare name is left to the not-found check. The message names the first
term that names a frame. When every reference is a plain `frame$column`
it gives the corrected call – the variables on their own, the data frame
as `data =`: the analyzed frame when the formula named it, otherwise the
named frame when it holds every variable the formula uses. A frame that
is neither (a lookup table) gets the save-it-first form instead. Called
by
[`.jst_check_formula_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_vars.md)
and, ahead of their computed-term refusal, by jcrosstab() and jplot()'s
formula path.

## Usage

``` r
.jst_check_formula_frames(formula, data, data_name, enclos = NULL)
```

## Arguments

- formula:

  The analysis formula as typed.

- data:

  The data frame the analysis uses.

- data_name:

  Character; its name.

- enclos:

  Environment the formula's other names resolve in; NULL gives
  `environment(formula)`, with the
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html) fallback
  the resolver uses.

## Value

Invisibly NULL; stops when a data frame is named.
