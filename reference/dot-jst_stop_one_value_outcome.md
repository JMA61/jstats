# Internal helper: stop on an outcome with one value in the analysis sample

A regression needs an outcome that varies, and a logistic regression an
outcome with both of its values. Until Session 346
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) fitted a
constant outcome,
[`summary.lm()`](https://rdrr.io/r/stats/summary.lm.html) warned
"essentially perfect fit" and the output stopped on R's "0 (non-NA)
cases";
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
said "'y' has values: 1 ... Use jrecode() to create a 0/1 coded version"
of an outcome coded 0/1 whose zeros a filter had removed. When a filter
names the outcome it is the cause, and the way out is to remove it;
otherwise the hedged line points at the filters when they excluded
cases.

## Usage

``` r
.jst_stop_one_value_outcome(
  dv,
  value,
  logistic,
  sample_info,
  data_name,
  before_listwise
)
```

## Arguments

- dv:

  Character(1); the outcome, as the model frame names it.

- value:

  Character(1); the one value, as it is shown.

- logistic:

  Logical(1); `TRUE` for
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md).

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- data_name:

  Character(1) or `NULL`.

- before_listwise:

  Logical(1); whether the filtered data already held one value of the
  outcome, before listwise deletion.

## Value

Never returns.
