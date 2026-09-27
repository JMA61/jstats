# Internal helper: build standardized sample_info block

Combines pipeline counts from .jst_apply_pipeline() with analysis-level
missing data information to produce the sample_info element included in
every analysis function's return value.

## Usage

``` r
.jst_build_sample_info(
  pipeline_counts,
  data,
  analysis_vars,
  n_analysis,
  transform_na = NULL,
  by_var = NULL
)
```

## Arguments

- pipeline_counts:

  List returned by .jst_apply_pipeline()\$pipeline_counts.

- data:

  Data frame after pipeline filtering (before analysis-level NA
  exclusion).

- analysis_vars:

  Character vector of variable names used in the analysis.

- n_analysis:

  Integer. Final N used in the analysis after listwise deletion on
  analysis variables.

- transform_na:

  Named integer vector from
  `.jst_resolve_formula_transforms()$introduced_na`: per computed term,
  the count of non-finite results the resolver converted to NA
  (AUDIT-025). NULL (the default) for callers without formula
  transforms; carried through for the Case Processing Summary.

- by_var:

  Character scalar, or NULL (the default): the grouping variable of a
  jdesc(by =) call (Session 316, AUDIT-027). When set, `n_analysis` is
  the count of cases that have a group, so `n_excluded_missing` is the
  count missing on the grouping variable; the Case Processing Summary
  renders it as the by = row and leaves the variable out of the N line's
  variable count.

## Value

A list with elements: n_original, n_after_complete, n_after_filter,
n_after_subset, n_analysis, n_excluded_missing, missing_by_var,
complete_active, filter_active, filter_expr, by_var (and the rest of the
pipeline counts).
