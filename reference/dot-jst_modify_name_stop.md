# Internal: the stop for modify = TRUE on data with no name

jdeclare_missing() (numeric and text) and jconvert(): a place (lst\$d)
gets the call assigned back to it, without modify = TRUE (Session 352);
an expression gets the naming line and the call on mydata (Session 383
gave the two one home; jrelabel() builds its own lines from the same two
sentences).

## Usage

``` r
.jst_modify_name_stop(data_sub_expr, call, fn_name, fn = NULL)
```

## Arguments

- data_sub_expr:

  The data argument as typed.

- call:

  The call as made, from
  [`sys.call()`](https://rdrr.io/r/base/sys.parent.html) in the exported
  function (or the call the caller holds).

- fn_name:

  Character(1). The function named in the offered line.

- fn:

  Character or NULL. As for
  [`.jst_no_vars_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_vars_stop.md).

## Value

Does not return; stops.
