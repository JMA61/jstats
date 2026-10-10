# Internal helper: stop on a predictor dummy-coded in the call that has one category

[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
build the dummies of a predictor named in `categorical =`, or of a
factor, text or logical variable, in the call, before the Case
Processing block. With one category the builder stopped there, "'gf' has
fewer than 2 categories. Cannot create dummy variables.", where a
predictor registered with
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) got the
Session 306 sentence under the block, naming the category, with the line
pointing at the filters when a filter excluded cases. The call now sets
such a predictor aside and this stop is made under the block, in the
registered predictor's words (Session 347). A filter whose condition
names the variable is named as the cause before this, by
[`.jst_stop_if_filter_kept_one()`](https://jma61.github.io/jstats/reference/dot-jst_stop_if_filter_kept_one.md).

## Usage

``` r
.jst_stop_one_category_in_call(one, sample_info, data_name)
```

## Arguments

- one:

  A list with `v`, the variable's name, and `x`, the variable as
  filtered; or `NULL`.

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- data_name:

  Character(1) or `NULL`.

## Value

Invisibly `NULL` when `one` is `NULL`; otherwise never returns.
