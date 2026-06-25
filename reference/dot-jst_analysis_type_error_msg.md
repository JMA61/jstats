# Internal helper: build the analysis type-gate error message

Internal helper: build the analysis type-gate error message

## Usage

``` r
.jst_analysis_type_error_msg(var_name, kind, fn_label)
```

## Arguments

- var_name:

  The offending variable's name.

- kind:

  The kind returned by
  [`.jst_var_kind()`](https://jma61.github.io/jstats/reference/dot-jst_var_kind.md).

- fn_label:

  A short noun phrase for the function (e.g. "a t-test").

## Value

Character scalar suitable for `stop(call. = FALSE)`.
