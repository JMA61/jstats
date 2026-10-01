# Internal helper: refuse a data frame's column where the frame goes

The resolver's stop for a function that does not take a single column,
given one as its first argument: `jcorr(d$Income, d$Age)` (Session 324,
the S322 jscreen/jcorr item, part B). Case 5 said "'d\$Income' not
found" and suggested `jcorr(MyData, d$Income)`; the column was found, it
is not a data frame, and that call would not run either. The fix line is
the user's own call with the frame first and its columns on their own
([`.jst_frame_column_fix()`](https://jma61.github.io/jstats/reference/dot-jst_frame_column_fix.md));
when that rebuild cannot be complete the sentence is given without a
call.

## Usage

``` r
.jst_frame_column_stop(data_sub, fcol, fn_name, cl, fun, envir)
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

Does not return; stops.
