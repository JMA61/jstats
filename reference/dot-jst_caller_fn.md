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

## Details

A frame counts only when its function belongs to the package – defined
in the same top-level environment as this helper, the jstats namespace
(AUDIT-015, Session 349). Before, any j-prefixed name did, so a user's
own wrapper took the blame: `justify_data <- function() jt(Y ~ X, d)`
stopped "justify_data(): Y and X were not found ...", where the call to
fix is [`jt()`](https://jma61.github.io/jstats/reference/jt.md). When
the master is sourced into the global environment (the older sandbox
route) the package and the user share that environment, and the name
alone decides, as it did.
