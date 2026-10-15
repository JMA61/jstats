# Internal helper: a data frame's name typed in quotes where the frame goes

Ruling R18 (Session 356): `jdesc("d", Age)`, `jsave("d", "f.rds")`,
`juse("d")`. When the string names a data frame in the caller's
workspace, the stop gives the call as typed without the quotes; the
formula functions' front door says the same of
`jt(Score ~ Gender, "d")`. Any other string is left to the caller.

## Usage

``` r
.jst_quoted_frame_stop(data_sub, eval_result, fn_name, envir, cl)
```

## Arguments

- data_sub:

  The first argument as typed.

- eval_result:

  Its evaluation, `list(value, failed)`.

- fn_name:

  Character(1); the user-facing function's name.

- envir:

  The caller's environment.

- cl:

  The caller's call, as typed.

## Value

Invisible NULL; stops on a quoted frame name.
