# Internal helper: validate and resolve the value.id display mode

Thin wrapper over `.jst_resolve_toggle("value.id", ...)` that first
validates a non-NULL per-call `value.id` argument against the
supported-token enum. `value.id` controls how a categorical variable's
per-code value labels surface (code, label, or both) wherever
categorical levels appear – the frequency-table Value column, group
headers, crosstab axes. It is distinct from `variable.id`, which governs
the one-per-variable descriptive label.

## Usage

``` r
.jst_resolve_value_id(
  per_call,
  allowed = c("both", "values", "labels", "legend", "legend.bottom")
)
```

## Arguments

- per_call:

  The value of the calling function's `value.id` argument: NULL (defer
  to joutput()), or one of `"both"`, `"values"`, `"labels"`, `"legend"`,
  `"legend.bottom"`.

- allowed:

  Character vector of the value.id modes the calling function accepts.
  Defaults to the full set;
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
  pass the reduced set (`"both"`, `"values"`, `"labels"`) so the "must
  be one of" message advertises only what they support, matching their
  separate rejection of the legend modes.

## Value

Single character token: one of `"both"`, `"values"`, `"labels"`,
`"legend"`, `"legend.bottom"`.

## Details

The five tokens: `"both"` (`"code: label"`), `"values"` (bare code),
`"labels"` (the value label, degrading to the bare code per code where
none exists), `"legend"` (bare codes in the table plus a code-\>label
legend block), `"legend.bottom"` (same, legend at the very end). The
legend modes keep the in-table category column compact when value labels
are long, mirroring `variable.id`'s legend modes.
