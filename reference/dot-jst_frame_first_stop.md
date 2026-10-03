# Internal helper: refuse an expression naming a data frame where the frame goes

The resolver's stop for a first argument that is neither a data frame
nor a plain `frame$column` but names a data frame, with no
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default to
fall back on: `jsubset(d$Age > 40)` (Session 330; the S324 item). Case 5
called it "not found" and suggested a call that names the frame twice.
When the function is
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md), the
expression is the call's only argument, one frame is named and every
reference to it rewrites to a variable the frame has, the fix line is
the call with the frame first and the variables on their own; otherwise
the sentence is given without a call.

## Usage

``` r
.jst_frame_first_stop(data_sub, frames, fn_name, cl, envir)
```

## Arguments

- data_sub:

  The substituted first argument.

- frames:

  Character; the data frames it names
  ([`.jst_frame_refs()`](https://jma61.github.io/jstats/reference/dot-jst_frame_refs.md)).

- fn_name:

  Character; the user-facing function's name.

- cl:

  The caller's call, as typed.

- envir:

  The caller's environment.

## Value

Does not return; stops.
