# Internal helper: expand registered dummy variables in a formula and data frame

Checks for jdummy registrations matching variables in the formula,
creates temporary dummy columns in the data frame, rewrites the formula,
and returns updated data, formula, reference category labels, and dummy
coefficient names. Used by jlm and jlogistic.

## Usage

``` r
.jst_expand_dummies(data, formula, data_name, numeric = NULL, count = NULL)
```

## Arguments

- data:

  The data frame.

- formula:

  The model formula.

- data_name:

  Character string name of the data frame (for looking up
  registrations).

- numeric:

  Optional character vector of variable names given a per-call numeric =
  override by the calling analysis function. A registered dummy named
  here is skipped from expansion (Option B) and left as its original
  numeric column; the stored registration is not changed.

- count:

  Optional character vector of variable names given a per-call count =
  override. Treated identically to `numeric` for expansion purposes (a
  count predictor enters a model as a numeric column).

## Value

A list with components:

- data:

  The data frame with dummy columns added.

- formula:

  The updated formula with dummy names.

- ref_cats:

  Character vector of "VarName = RefLabel" strings.

- expanded_originals:

  Character vector of the original variable names actually expanded into
  dummy columns (registered, minus any skipped by a per-call
  numeric=/count= override, minus any not in the formula). Callers use
  this to identify which originals were replaced.

- dummy_coef_names:

  Character vector of dummy column names (for blanking beta).

## Details

A per-call numeric = or count = naming a registered dummy IV overrides
the registration for that one call (Option B): the variable is skipped
before expansion – left intact as its original numeric column rather
than expanded then reverted – and a message (registered dichotomy) or
warning (registered multi-category dummy) is emitted. The stored
registration is never mutated.
