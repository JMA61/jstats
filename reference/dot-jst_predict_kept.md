# Internal helper: predict from a model, without the rank-deficient warning

A model whose fit dropped a term as an exact linear combination of the
others (an NA coefficient) predicts from the terms it kept, and
[`predict.lm()`](https://rdrr.io/r/stats/predict.lm.html) – which
[`predict.glm()`](https://rdrr.io/r/stats/predict.glm.html) calls –
warns "prediction from rank-deficient fit; attr(\*, "non-estim") has
doubtful cases" whenever the grid holds the dropped term at a value the
kept terms do not imply: once for the fit plot and once per effect plot
(Session 359; the S347 item). jlm() and jlogistic() have already said
which term the fit dropped
([`.jst_warn_aliased()`](https://jma61.github.io/jstats/reference/dot-jst_warn_aliased.md)),
and the line drawn is the kept terms' prediction, so that one warning is
muffled here. Any other warning passes.

## Usage

``` r
.jst_predict_kept(...)
```

## Arguments

- ...:

  Passed to [`stats::predict()`](https://rdrr.io/r/stats/predict.html).

## Value

What [`stats::predict()`](https://rdrr.io/r/stats/predict.html) returns.
