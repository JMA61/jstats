# Internal helper: the call a data frame's column should have been

Rebuilds the caller's call with the frame first and the column after it
– `jcorr(d$Income, d$Age, method = "spearman")` becomes
`jcorr(d, Income, Age, method = "spearman")` – for
[`.jst_frame_column_stop()`](https://jma61.github.io/jstats/reference/dot-jst_frame_column_stop.md).
The frame's other columns become bare names through
[`.jst_strip_frame_refs()`](https://jma61.github.io/jstats/reference/dot-jst_strip_frame_refs.md),
a named argument keeps its name, and the column goes where the function
takes variables: straight after the frame when its second formal is
`...`, `var`, `orig.var` or `expr`, or when nothing positional follows
(`jconvert(d$Stress, to = "stata")`). Gives NULL – the sentence without
a call – when the rebuild cannot be complete: the argument is not found
in the call, a positional argument would land in the wrong slot, a
summary of the frame is used (`mean(d$Age)`), or a data frame is still
named after the rewrite (another frame's column, `d[, 2]`).

## Usage

``` r
.jst_frame_column_fix(data_sub, fcol, fn_name, cl, fun, envir)
```

## Arguments

- data_sub:

  The substituted first argument.

- fcol:

  Its
  [`.jst_frame_column()`](https://jma61.github.io/jstats/reference/dot-jst_frame_column.md)
  result.

- fn_name:

  Character; the user-facing function's name.

- cl:

  The caller's call, as typed.

- fun:

  The caller's function, for its formals.

- envir:

  The caller's environment.

## Value

Character; the rebuilt call on one line, or NULL.
