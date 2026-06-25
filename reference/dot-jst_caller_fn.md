# Internal helper: detect the user-facing function on the call stack

Walks the call stack from the outermost frame inward and returns the
name of the first exported jstats function (j-prefixed) found, reducing
an S3 method name to its generic (e.g. jplot.jst_lm -\> jplot). Used so
that shared validation helpers can name the function the user actually
called, even though errors are signaled with call. = FALSE. Returns NULL
when no jstats frame is on the stack.

## Usage

``` r
.jst_caller_fn()
```

## Value

A function name string, or NULL.
