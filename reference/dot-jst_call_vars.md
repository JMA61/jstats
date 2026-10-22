# Internal helper: the variables a call names besides its data

The names its unnamed arguments read, the one typed as the data left
out: `jfreq(dd[dd$Age > 40, ], Group)` names Group. For ruling R36's
match inside an expression
([`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md)).

## Usage

``` r
.jst_call_vars(cl, data_sub)
```

## Arguments

- cl:

  The call as typed, or NULL.

- data_sub:

  The argument given as the data.

## Value

Character, possibly empty.
