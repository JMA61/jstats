# Internal helper: apply a logical mask expression to a data frame

Shared mechanic for Step 2 (persistent jsubset) and Step 3 (per-call
`subset =` argument) of
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md).
Runs `expr` through
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md)
– which evaluates it in the data + caller environment and stops on
anything that cannot select rows – coerces `NA`s in the mask to `FALSE`,
and returns the filtered data frame. The two callers differ in upstream
source (joptions state vs. argument) and downstream bookkeeping (which
`sample_info` slot is populated); the masking step itself is identical.
This is the package's single row-selection site for user filters
(Session 288 scan). Until Session 330 it took `on_error` and
`stage_label`: a stored filter whose evaluation failed warned and kept
every row. Both origins stop now, so both arguments are gone.

## Usage

``` r
.jst_apply_mask(
  data,
  expr,
  envir,
  origin,
  expr_str,
  data_name = NULL,
  n_frame = NULL
)
```

## Arguments

- data:

  Data frame to mask.

- expr:

  Unevaluated logical expression (a language object).

- envir:

  Environment to evaluate `expr` in. Data columns take precedence;
  `envir` provides fallback bindings.

- origin:

  One of `"stored"` or `"call"`; selects the wording of every refusal.

- expr_str:

  Character. The deparsed expression, echoed in the refusals.

- data_name:

  Character. The data frame's name; the stored-filter errors build their
  exits from it.

- n_frame:

  Integer or NULL. The frame's row count before the pipeline's filters,
  for the per-call recycling stop.

## Value

The data frame filtered to rows where `expr` evaluates to `TRUE` (`NA`
treated as `FALSE`).
