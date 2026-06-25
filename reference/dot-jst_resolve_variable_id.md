# Internal helper: validate and resolve the variable.id display mode

Thin wrapper over `.jst_resolve_toggle("variable.id", ...)` that first
validates a non-NULL per-call `variable.id` argument against the
five-token enum. Every analysis function's `variable.id =` argument is a
string-only enum (no logical aliases); a bad token errors here with a
consistent message rather than silently passing through to the renderer.
(`variable.id` controls the one-per-variable descriptive label; the
distinct `value.id` control governs the per-code value-label mapping –
see `.jst_resolve_value_id`.)

## Usage

``` r
.jst_resolve_variable_id(per_call)
```

## Arguments

- per_call:

  The value of the calling function's `variable.id` argument: NULL
  (defer to joutput()), or one of `"both"`, `"names"`, `"labels"`,
  `"legend"`, `"legend.bottom"`.

## Value

Single character token: one of `"both"`, `"names"`, `"labels"`,
`"legend"`, `"legend.bottom"`.

## Details

The five tokens parallel `value.id`'s: `"names"` (bare variable name),
`"labels"` (the variable label in place of the name), `"both"`
(`"name: label"`), `"legend"` (names in the table plus a name-\>label
legend block), `"legend.bottom"` (same, legend at the very end).
