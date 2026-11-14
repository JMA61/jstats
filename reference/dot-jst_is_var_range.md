# Internal helper: whether an expression is a range of variables

`A:B` with a name at each end, as a variable list takes it (Session 426,
ruling R90). Used where the input stands in the data frame's place – the
resolver's lines when no data frame is named, and ruling R23's check of
the line it offers – so a range there is read as the call's variables,
as a name is. A range of numbers (`1:3`) is not one.

## Usage

``` r
.jst_is_var_range(e)
```

## Arguments

- e:

  An expression.

## Value

TRUE or FALSE.
