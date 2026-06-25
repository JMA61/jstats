# Internal helper: intent-based categorical classifier

Returns TRUE only when the user has explicitly signalled that a variable
should be treated as categorical. This helper answers the question
"should this variable be behaviorally treated as categorical?" – for
decisions like factoring in regression, expanding to dummies, or
excluding from a correlation matrix.

## Usage

``` r
.jst_is_categorical(x, var_name = NULL, data_name = NULL, override = NULL)
```

## Arguments

- x:

  A variable (vector).

- var_name:

  Optional character string. The variable's column name. Required for
  the jdummy() registration check.

- data_name:

  Optional character string. The data frame's name. Required for the
  jdummy() registration check.

- override:

  Optional per-call asserted role for `x`: one of "categorical",
  "numeric", or "count" (or NULL for no override). When supplied it
  takes precedence over registration and structure, matching the tier-1
  per-call slot in the classification resolver.

## Value

TRUE if the user has declared the variable categorical, FALSE otherwise.

## Details

Paired with
[`.jst_is_discrete_integer()`](https://jma61.github.io/jstats/reference/dot-jst_is_discrete_integer.md)
(the structural helper). Callers needing behavioral decisions use this
helper; callers needing a warning trigger typically check this helper
first, and fall back to the structural helper only if this one returns
FALSE.

Rules (first match wins):

1.  Per-call `override`: "categorical" -\> TRUE; "numeric" or "count"
    -\> FALSE (a count is numeric-like for the categorical-vs- numeric
    decision this helper answers). NULL falls through.

2.  jdummy() registration for `var_name` on `data_name` -\> categorical.

3.  Class factor, logical, or character -\> categorical.

4.  Otherwise -\> FALSE.

NA preprocessing is expected to have run already via
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
before this helper is called on analysis data, though neither rule
depends on NA state.
