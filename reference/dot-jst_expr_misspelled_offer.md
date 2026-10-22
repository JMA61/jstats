# Internal helper: ruling R36's offer for a name inside an expression

For
[`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md):
the one name found nowhere in the expression given as the data is read
as a data frame's name typed wrong when ruling R36's conditions hold for
it
([`.jst_misspelled_frame()`](https://jma61.github.io/jstats/reference/dot-jst_misspelled_frame.md))
– the variables counted are those the call names and those the
expression reads from the name
([`.jst_expr_columns()`](https://jma61.github.io/jstats/reference/dot-jst_expr_columns.md))
– and the expression with that frame in its place
([`.jst_expr_rename()`](https://jma61.github.io/jstats/reference/dot-jst_expr_rename.md))
gives a data frame holding the call's variables, so the line offered
runs: `jt(Score ~ Group, d[d$Age > 40, ])`. Evaluating that expression
is evaluating the user's own, one name changed. The stop is
[`.jst_misspelled_frame_stop()`](https://jma61.github.io/jstats/reference/dot-jst_misspelled_frame_stop.md)'s,
which also checks the line for ruling R23.

## Usage

``` r
.jst_expr_misspelled_offer(
  data_sub,
  nm,
  fn,
  envir,
  cl,
  vars,
  vector_ok = FALSE
)
```

## Arguments

- data_sub:

  The expression as typed.

- nm:

  Character(1). The name found nowhere.

- fn:

  Character(1). The user-facing function's name.

- envir:

  The caller's environment.

- cl:

  The call as typed.

- vars:

  Character. The variables the call names besides the data.

- vector_ok:

  Logical. The function takes a single column, so the expression may
  give one.

## Value

Invisible NULL when nothing is offered; otherwise stops.
