# Internal helper: validate and resolve the jcorr correlation-cell layout

Resolves the `layout` argument of
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) to one of
`"wide"` or `"stacked"`. Unlike the joutput()-backed display toggles,
this layout choice is jcorr-specific (the only function that renders
composite r / p / N cells), so its global default lives in joptions()
rather than joutput(): a per-call value wins, else the `corr.layout`
joptions slot, else the built-in default of "wide".

## Usage

``` r
.jst_resolve_corr_layout(per_call)
```

## Arguments

- per_call:

  The value of jcorr()'s `layout` argument: NULL (defer to joptions()),
  or one of `"wide"`, `"stacked"`.

## Value

Single character token: `"wide"` or `"stacked"`.
