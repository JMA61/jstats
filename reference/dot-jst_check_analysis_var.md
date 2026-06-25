# Internal helper: gate a variable for use in an analysis function

Stops with a clean, variable-naming error when the variable's type
cannot be used in the calling analysis. Date/time, complex, list, and
raw are refused for every role; text (factor or character) and
numbers-stored-as- text are additionally refused when a numeric variable
is required. Accepted variables pass through; the returned kind carries
the coerced numeric for callers that want it.

## Usage

``` r
.jst_check_analysis_var(
  x,
  var_name,
  requires_numeric = TRUE,
  fn_label = "this analysis"
)
```

## Arguments

- x:

  The variable / column.

- var_name:

  The variable's name (for the message).

- requires_numeric:

  TRUE for roles that need a numeric variable (continuous DV,
  correlation variable, scale item); FALSE for roles where a categorical
  variable is valid (grouping variable, regression predictor, logistic
  DV).

- fn_label:

  A short noun phrase for the function (e.g. "a t-test").

## Value

Invisibly, the
[`.jst_var_kind()`](https://jma61.github.io/jstats/reference/dot-jst_var_kind.md)
result.
