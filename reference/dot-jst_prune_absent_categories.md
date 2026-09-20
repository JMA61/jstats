# Internal helper: drop the dummies of categories absent from the analysis sample

A dummy registration describes the categories a variable HAD when it was
registered (or, for an in-flight registration, when the filtered frame
was expanded). The analysis sample can hold fewer: a
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) or
`subset =` filter removes a category, or listwise deletion on another
variable takes every case of one. Before Session 306 the dummies were
fit as registered. An absent NON-reference category gave an all-zero
dummy, and the zero-variance guard stopped on its internal column name
with a single-category diagnosis. An absent REFERENCE category was
worse: its dummies partitioned the sample, so the fit dropped the last
one as aliased and silently re-referenced the contrasts to that
category, while the coefficient table's header still named the
registered reference over rows that no longer compared against it, the
collinearity warning the only hint.

## Usage

``` r
.jst_prune_absent_categories(
  mf,
  data,
  formula,
  dummy_regs,
  expanded_originals,
  auto_cat_regs,
  dummy_coef_names,
  ref_cats,
  auto_ref_cats,
  value_mode
)
```

## Arguments

- mf:

  The listwise-complete model frame built from `formula` on `data`.

- data:

  The post-pipeline analysis frame the model frame was built from,
  holding both the dummy columns and the original variables.

- formula:

  The expanded model formula.

- dummy_regs:

  The frame's stored registration list, or NULL.

- expanded_originals:

  Names of the registered variables actually expanded (a per-call
  numeric =/count = skip is not).

- auto_cat_regs:

  Named list of in-flight registrations, keyed by variable name.

- dummy_coef_names:

  Character vector of dummy column names in the model.

- ref_cats, auto_ref_cats:

  The "Var = RefLabel" vectors for the stored and in-flight
  registrations.

- value_mode:

  Resolved value.id mode for the category labels in the note, the same
  one the coefficient table uses.

## Value

A list with the possibly-updated `formula`, `mf`, `dummy_regs`,
`auto_cat_regs`, `dummy_coef_names`, `ref_cats` and `auto_ref_cats`,
plus `dropped`, the dummy column names removed (empty when nothing was).

## Details

This helper runs once the listwise-complete model frame exists, so
presence is judged on the analysis sample itself, whichever stage
emptied a category. For each expanded registration, stored or in-flight,
it finds the registered categories with no case among the analysis rows.
An absent reference is replaced by the first present category in
registration order (the `ref = "auto"` rule): because the dummies are
plain indicators, that is done by dropping the new reference's own dummy
from the formula, which leaves the remaining dummies as exactly the
treatment coding against it. An absent non-reference category's dummy is
dropped. Both are reported in one consequential note per variable (Rule
R names the condition; Rule F spaces several), and a per-call copy of
the registration carrying the new reference and the trimmed dummy set
replaces the original in the returned lists, so the header, the category
rows and the returned `ref_cats` describe the model that was fit. The
stored registration is never touched. A variable left with fewer than
two present categories cannot be dummy-coded and stops with a guided
error naming the VARIABLE, where the zero-variance guard named its dummy
columns.

The dropped dummy columns stay in `data`; only the formula, the model
frame and `dummy_coef_names` lose them. Dropping a column cannot change
the analysis rows – a variable's dummies are missing together – so the
rebuilt frame has the same rows, which is asserted.
