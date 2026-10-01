# Internal helper: refuse a data frame named in a filter condition

The condition sibling of
[`.jst_check_formula_frames()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_frames.md)
(the S322 subset item, built in Session 323). A filter is evaluated with
the data as data and the caller's frame as enclosure, so
`subset = d$Income < 45` reads Income from the user's RAW frame: a
declared -99 is a number below 45 there, and the case is kept, where
`subset = Income < 45` sets it aside as missing. Called at
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)'s set
time (origin `"set"`, after the syntax check, before the dry run) and on
a per-call `subset =` at apply time (origin `"call"`, in the pipeline's
Step 3); the vector path refuses its own form in
[`.jst_vector_recurse()`](https://jma61.github.io/jstats/reference/dot-jst_vector_recurse.md).
The fix line, the condition with the variables on their own, is printed
when the frame is the one being analyzed and every reference rewrites; a
frame that is not (a lookup table) gets the save-it-first form. At set
time an earlier filter for the frame is reported unchanged, as the shape
refusal does.

## Usage

``` r
.jst_check_condition_frames(
  expr,
  expr_str,
  data,
  envir,
  origin = c("set", "call"),
  data_name = NULL,
  named_frame = FALSE,
  prior = FALSE
)
```

## Arguments

- expr:

  The unevaluated condition.

- expr_str:

  Character; the condition as typed.

- data:

  The data frame the condition will be evaluated against.

- envir:

  The environment the condition's other names resolve in.

- origin:

  `"set"`
  ([`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md))
  or `"call"` (`subset =`).

- data_name:

  Character; the data frame's name.

- named_frame:

  Logical. For `"set"`: the user named the frame in the call, so the fix
  line echoes that form.

- prior:

  Logical. For `"set"`: an earlier filter exists for the frame.

## Value

Invisibly NULL; stops when a data frame is named.
