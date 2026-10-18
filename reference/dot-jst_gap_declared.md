# Internal helper: whether the variables a jdeclare_missing() call names already carry declarations of their own

Such a variable meets no convention gate: jdeclare_missing() follows its
own form (Session 345). Used by
[`.jst_call_gap()`](https://jma61.github.io/jstats/reference/dot-jst_call_gap.md);
FALSE when the data frame or the variables cannot be read, so the gap is
said.

## Usage

``` r
.jst_gap_declared(a, vars_dots, envir)
```

## Arguments

- a:

  The matched call's arguments
  ([`.jst_call_gap()`](https://jma61.github.io/jstats/reference/dot-jst_call_gap.md)).

- vars_dots:

  The call's unnamed variable arguments.

- envir:

  Where the data frame is looked for.

## Value

TRUE or FALSE.
