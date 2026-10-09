# Internal helper: stop on a predictor with one value in the analysis sample

[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
cannot estimate a coefficient for a predictor that takes a single value.
The predictor is the subject of the sentence (voice Rule AD), and each
sentence has a line (Rule E). A second line points at the filters only
when a filter excluded cases from this analysis: until Session 346 the
stop ended "This often happens when jsubset() restricts the sample to a
single category of a variable that is then used as a predictor" on a
frame with no filter of any kind (the S338 item).

## Usage

``` r
.jst_stop_constant_predictors(vars, sample_info, data_name, data = NULL)
```

## Arguments

- vars:

  Character vector; the predictors, as the model frame names them.

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- data_name:

  Character(1) or `NULL`; the data frame's name, for its stored
  settings.

- data:

  The filtered data before listwise deletion, or `NULL`; a filter is
  named as the cause only where these data already hold one value
  ([`.jst_one_value_before_listwise()`](https://jma61.github.io/jstats/reference/dot-jst_one_value_before_listwise.md)).

## Value

Never returns.

## Details

When a filter's condition names the predictor –
`subset = PriorTherapy == 1` with PriorTherapy in the formula – the
filter is the cause and the call asks for two things that cannot both be
had, so the stop says what the filter did and gives both ways out:
remove the filter to estimate the coefficient, or remove the predictor
to analyze only those cases (Session 346; Jeff, on the hedged form: "the
error message doesn't address the real problem").
