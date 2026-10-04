# Internal helper: jsubset()'s check on a third positional input

`jsubset(d, Age < 40, Sex == 1)` puts its third input in `clear.all`,
where evaluating it gave R's own "object 'Sex' not found". Read from the
call as typed, before anything is evaluated, and refused as more than
one condition
([`.jst_one_condition_stop()`](https://jma61.github.io/jstats/reference/dot-jst_one_condition_stop.md)).
The first input is evaluated here only to tell a data frame from a
condition, and only on this path, which always stops unless one of the
inputs is `off`, `on` or `NULL`; those calls are left to fail as they
did.

## Usage

``` r
.jst_extra_conditions_stop(pos, envir)
```

## Arguments

- pos:

  The call's unnamed inputs, unevaluated, three or more.

- envir:

  The caller's environment.

## Value

`invisible(NULL)`, or stops.
