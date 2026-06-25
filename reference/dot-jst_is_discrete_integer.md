# Internal helper: structural categorical-looking classifier

Returns TRUE when a variable's shape suggests it *could* be categorical
but has not been explicitly declared as such via jdummy() or a per-call
override. This helper answers a different question from
[`.jst_is_categorical()`](https://jma61.github.io/jstats/reference/dot-jst_is_categorical.md):
it describes the structure of the values, not the user's intent.

## Usage

``` r
.jst_is_discrete_integer(x, var_name = NULL, data_name = NULL)
```

## Arguments

- x:

  A variable (vector).

- var_name:

  Optional character string. The variable's column name. Accepted for
  call-site symmetry with
  [`.jst_is_categorical()`](https://jma61.github.io/jstats/reference/dot-jst_is_categorical.md);
  not currently used in this helper's logic.

- data_name:

  Optional character string. The data frame's name. Accepted for
  call-site symmetry with
  [`.jst_is_categorical()`](https://jma61.github.io/jstats/reference/dot-jst_is_categorical.md);
  not currently used in this helper's logic.

## Value

TRUE if the variable has categorical-like structure, FALSE otherwise.

## Details

Used primarily as a *warning trigger*: callers that want to alert users
to "this looks like it should probably have been jdummy-registered or
passed via categorical=" check this helper. It does NOT license
behavioral changes – analysis functions should only factor variables
based on the intent helper, not this one.

Two structural rules, checked in order. First match wins.

1.  haven_labelled (including haven_labelled_spss) with value labels
    attached to at least one non-missing value present in the data, AND
    \<= 6 unique non-NA values overall -\> TRUE. Character-type labelled
    vectors return TRUE immediately. Numeric labelled vectors require
    BOTH that at least one labelled code actually appears in the
    (post-NA-preprocessing) data AND that there are no more than 6
    distinct values present (variables with 7+ distinct values have
    enough categories that linear-model assumptions hold reasonably
    well).

2.  Plain numeric (or haven_labelled numeric that fell through 1) with
    all whole-number values, min \>= 0, max \<= 6, and at least 2 unique
    non-NA values -\> TRUE.

Bounds on both rules (0 to 6 inclusive) support the common view that an
interval-like variable with 6+ categories is adequately continuous for
linear-model use. 7-category Likert coded as 0-6 or 1-6 still triggers
the warning; coded as 1-7 does not. A 10-category labelled Income
variable falls through both rules and is treated as continuous.

NA preprocessing (auto-conversion of values labelled "Missing" to NA) is
expected to have run already via
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
before this helper is called on analysis data. Rule 1's "labelled codes
present in data" check depends on this ordering.
