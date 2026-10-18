# Internal helper: a value given where the data frame goes

jplot(1:3), jplot(list(1)), jdesc(5, Age) on a function that does not
take a single column: an expression that names no variable is neither a
name nor a condition. The resolver had asked whether it was a variable
name, or said it "needs a data frame", and put it back in the line
beside MyData – jplot(MyData, 1:3) (Session 371, the remedy-line audit;
the S369 seed). It is said to be no data frame, and the lines are the
call without it, the data frame named the one in the workspace holding
the call's other variables (MyData with none or several). A call left
with no variable gets ruling R23's stop.

## Usage

``` r
.jst_value_data_stop(data_sub, data_str, fn_name, envir)
```

## Arguments

- data_sub:

  The expression given as the data.

- data_str:

  Its text.

- fn_name:

  Character. The function's name.

- envir:

  The caller's environment.

## Value

Does not return; stops.
