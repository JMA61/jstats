# Internal helper: the diagnostics a call is to show

Precedence as for every display setting: the call's own `diagnostics =`,
then the one stored by
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md), then
off. The output level is not consulted (Session 346).

## Usage

``` r
.jst_resolve_diagnostics(per_call, fn)
```

## Arguments

- per_call:

  The calling function's `diagnostics` argument.

- fn:

  Character(1); the calling function, a name of `.jst_diagnostic_sets`.

## Value

Character vector: the names to show, in the set's own order; empty when
none.
