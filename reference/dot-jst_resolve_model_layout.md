# Internal helper: the order of a model's coefficient table and fit block

The call's own `model.layout`, then
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s,
then `"coefficients"` (Session 375; the Session 63 item): jlm() and
jlogistic() print the Coefficients table first and the fit statistics
after it, or under `"fit"` the other way round.

## Usage

``` r
.jst_resolve_model_layout(per_call, fn)
```

## Arguments

- per_call:

  The call's `model.layout` argument.

- fn:

  The function's name.

## Value

`"coefficients"` or `"fit"`.
