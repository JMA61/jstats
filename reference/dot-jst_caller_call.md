# Internal helper: the user's call, found on the call stack

The call of the first function of the package's own namespace on the
stack whose name is j-prefixed – the frame
[`.jst_caller_fn()`](https://jma61.github.io/jstats/reference/dot-jst_caller_fn.md)
names – with its head set to the function's generic name, so a line
built from it reads as the user typed it.

## Usage

``` r
.jst_caller_call()
```

## Value

A call, or NULL.
