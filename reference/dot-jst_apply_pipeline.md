# Internal helper: apply the full data pipeline and return filtered data + messages

Order of operations:

1.  jcomplete (listwise deletion for registered variables)

2.  jsubset (persistent case-selection expression)

3.  subset (one-off per-call case-selection expression)

## Usage

``` r
.jst_apply_pipeline(
  data,
  data_name,
  is_default,
  subset_expr = NULL,
  envir = parent.frame()
)
```

## Arguments

- data:

  The data frame.

- data_name:

  Character string name of the data frame.

- is_default:

  Logical. TRUE if the data frame came from juse().

- subset_expr:

  An unevaluated expression for one-off subsetting, or NULL.

- envir:

  The environment in which to evaluate expressions.

## Value

A list with components:

- data:

  The filtered data frame.

- msgs:

  Character vector of info-line messages to print.

- pipeline_counts:

  A list of pipeline counts: `n_original`, `n_after_complete`,
  `n_after_filter`, `n_after_subset` (each NULL if that step was not
  active), `complete_active`, `filter_active`, `filter_expr`.

## Details

jcomplete and jsubset are keyed per-dataset. They apply whenever the
matching dataset is used, regardless of whether that dataset was
supplied via the juse() default or specified explicitly in the function
call. This matches the SPSS FILTER model: persistent state remains in
effect until explicitly turned off via jsubset(off) / jcomplete(off).

When the current dataset has no jsubset / jcomplete set but at least one
other dataset does have an active setting, a yellow-colored note is
included in the pipeline messages to remind the user that case selection
is not active for this particular dataset.
