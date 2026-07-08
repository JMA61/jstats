# Internal helper: clean up factor coefficient names for output

By default, R concatenates factor variable names with level names when
producing regression coefficient labels (e.g. "GenderRFemale"). This
helper rewrites factor terms to the parenthetical "Var (Level)" form
(e.g. "GenderR (Female)"), and gives a numeric dichotomy whose two codes
differ by exactly 1 the matching "Var (Level)" form, showing the HIGHER
code's value label (haven) or its value (Session 127) – there the slope
equals the higher-vs-lower category contrast. Wider-spaced codes stay
bare so the label cannot misrepresent a genuine per-unit slope. Columns
named in skip are left entirely untouched: the jlm()/jlogistic() call
sites pass their machine-generated dummy column names, so generated 0/1
dummies keep bare names – they are already named clearly (e.g.
"Education_Some_college"), a trailing "(1)" adds nothing on a column
that can only be 0/1, and the grouped multi-category display
(.jst_group_dummy_coefs) matches rows by those bare names, so decorating
them silently defeats the grouped layout (Session 176).

## Usage

``` r
.jst_clean_coef_names(
  coef_names,
  data,
  iv_names,
  sep = "-",
  skip = character(0)
)
```

## Arguments

- coef_names:

  Character vector of coefficient names from a fitted model.

- data:

  Data frame used to fit the model (post-conversion).

- iv_names:

  Character vector of IV names from the model formula.

- sep:

  Character. Separator to insert. Default is "-".

- skip:

  Character vector of column names to leave untouched (no factor
  separation, no dichotomy parenthetical). The jlm()/jlogistic() call
  sites pass their machine-generated dummy column names here. Default
  character(0).

## Value

Character vector of the same length as coef_names, with factor
coefficient names separated.
