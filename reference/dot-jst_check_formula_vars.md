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
.jst_check_formula_vars(
  formula,
  data,
  data_name,
  default_used = FALSE,
  n_frame = NULL
)
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

- n_frame:

  Integer or NULL; the frame's row count before the pipeline's filters
  (`pipeline_counts$n_original`), which tells the recycling stop's two
  forms apart. NULL is read as `nrow(data)`.

## Value

The data variables the formula names, constants left out, in order of
first appearance – the list the Case Processing Summary receives as
`analysis_vars`. Stops instead when a name is found nowhere, a data
frame is named inside a term, a power is refused, or a workspace vector
would be recycled.

## Details

A third refusal follows them (Session 324, the second deliberate
departure from [`lm()`](https://rdrr.io/r/stats/lm.html) parity): a
workspace vector with more than one value but not one per row of `data`
– the frame after its filters, before cases with missing values are set
aside, the rows the resolver computes the term on – used value by value
inside a computed term
([`.jst_formula_recycled()`](https://jma61.github.io/jstats/reference/dot-jst_formula_recycled.md)).
[`lm()`](https://rdrr.io/r/stats/lm.html) recycles it. A vector with one
value per row of the frame as given, which a filter has since cut down,
gets the fix of adding it to the frame, where the filter reaches it; any
other length gets the requirement.
