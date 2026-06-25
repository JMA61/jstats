# Internal helper: apply a logical mask expression to a data frame

Shared mechanic for Step 2 (persistent jsubset) and Step 3 (per-call
`subset =` argument) of
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md).
Evaluates `expr` in the data + caller environment, coerces `NA`s in the
resulting mask to `FALSE`, and returns the filtered data frame. The two
callers differ in upstream source (joptions state vs. argument) and
downstream bookkeeping (which `sample_info` slot is populated); the
masking step itself is identical.

## Usage

``` r
.jst_apply_mask(data, expr, envir, on_error, stage_label)
```

## Arguments

- data:

  Data frame to mask.

- expr:

  Unevaluated logical expression (a language object).

- envir:

  Environment to evaluate `expr` in. Data columns take precedence;
  `envir` provides fallback bindings.

- on_error:

  One of `"warn"` or `"stop"`. `"warn"` emits a warning and returns the
  data unchanged – used for the persistent jsubset state, where the
  expression was validated when set and a runtime failure is unexpected.
  `"stop"` raises an error – used for the per-call `subset =` argument,
  where a broken expression is a user error at call time.

- stage_label:

  Character. Prefix used in the error/warning message (e.g. `"jsubset"`
  or `"Subset"`) so failures are attributable to the right pipeline
  stage.

## Value

The data frame filtered to rows where `expr` evaluates to `TRUE` (`NA`
treated as `FALSE`).
