# Internal helper: wrap a bare column for the vector-input path

Builds the one-column data frame that jdesc(), jfreq() and jscreen()
analyze when given a bare column, as in `jdesc(community$Age)`, plus the
names their messages use: the column as typed, the variable name (the
part after the last dollar sign), and the frame it came from when typed
as frame dollar column – MyData, the placeholder frame, otherwise. A
column of a data frame (the resolver's `first_arg_frame`, Session 324)
takes both names from that frame, so `d[["Age"]]` reads as Age from d,
and is marked `in_frame` for
[`.jst_vector_recurse()`](https://jma61.github.io/jstats/reference/dot-jst_vector_recurse.md).

## Usage

``` r
.jst_vector_frame(arg1)
```

## Arguments

- arg1:

  The
  [`.jst_resolve_first_arg()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_first_arg.md)
  result, mode `vector_input`.

## Value

A list with `frame`, `typed`, `var`, `frame_nm` and `in_frame`.
