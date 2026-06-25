# Internal helper: build standardized sample_info block

Combines pipeline counts from .jst_apply_pipeline() with analysis-level
missing data information to produce the sample_info element included in
every analysis function's return value.

## Usage

``` r
.jst_build_sample_info(pipeline_counts, data, analysis_vars, n_analysis)
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

## Value

A list with elements: n_original, n_after_complete, n_after_filter,
n_after_subset, n_analysis, n_excluded_missing, missing_by_var,
complete_active, filter_active, filter_expr.
