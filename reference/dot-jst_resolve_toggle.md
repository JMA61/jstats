# Internal helper: resolve a display toggle value

Implements three-tier precedence: (1) explicit per-call argument wins,
(2) individual joutput() toggle override, (3) joutput() level default.
Per-call arguments use NULL to mean "I didn't specify – defer to
joutput()".

## Usage

``` r
.jst_resolve_toggle(name, per_call_value)
```

## Arguments

- name:

  Character. Toggle name (e.g. "effect.size", "means.ci", "levene").

- per_call_value:

  The value passed by the user in the function call, or NULL if not
  specified.

## Value

Logical. TRUE or FALSE.
