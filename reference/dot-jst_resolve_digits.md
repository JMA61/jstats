# Internal helper: validate and resolve the digits (decimal places) setting

Thin wrapper over `.jst_resolve_toggle("digits", ...)` that first
validates a non-NULL per-call `digits` argument: it must be a single
whole number in the range 0-7. The resolved value is the number of
decimal places shown for continuous tabular statistics; it never governs
p-values, case-processing percentages, integer quantities (N, df,
counts), or the multicollinearity-warning prose numbers (all fixed by
their own conventions). Returns an integer.

## Usage

``` r
.jst_resolve_digits(per_call)
```

## Arguments

- per_call:

  The value of the calling function's `digits` argument, or NULL to
  defer to joutput().

## Value

Integer in 0-7.
