# Internal helper: the default route's call, its arguments named

The second route of the no-data-frame stops ("Or set a default first,
then run the call:") runs the call with no data frame, and jrecode(),
jencode() and jrelabel() refuse an unnamed argument after the variable
there ("when the data argument is omitted, all subsequent arguments must
be named."). The route had been the call as typed, jrecode(Age, "1=2"),
which stopped on that rule (Session 371, the remedy-line audit). For
those three the arguments after the variable are named, by the
function's own argument names, and an empty first argument is dropped;
every other function's call is returned as typed.

## Usage

``` r
.jst_default_route(fn, typed)
```

## Arguments

- fn:

  Character. The function's name.

- typed:

  The call as typed.

## Value

A call.
