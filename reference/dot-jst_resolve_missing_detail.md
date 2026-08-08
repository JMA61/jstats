# Internal helper: validate and resolve the missing-value detail tier

Resolves
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)'s
`missing.detail` argument to one of `"totals"`, `"per_code"`, or
`"all"`. Like `corr.layout` and unlike the joutput()-backed display
toggles, this choice is specific to the one function that renders a
missing-value breakdown per variable, so its global default lives in
joptions() rather than joutput(): a per-call value wins, else the
`missing.detail` joptions slot, else the built-in default of
`"per_code"`.

## Usage

``` r
.jst_resolve_missing_detail(per_call)
```

## Arguments

- per_call:

  The value of
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)'s
  `missing.detail` argument: NULL (defer to joptions()), or one of
  `"totals"`, `"per_code"`, `"all"`.

## Value

Single character token: `"totals"`, `"per_code"`, or `"all"`.

## Details

Not a platform-spec string (it names no statistical platform), so it is
matched exactly, as `corr.layout` and `case.processing.detail` are.
