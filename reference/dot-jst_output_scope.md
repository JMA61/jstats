# Internal helper: run an analysis function's body, printing or silent

Wraps the whole body of each analysis function (jdesc, jfreq, jt, jaov,
jcrosstab, jlm, jlogistic, jcorr, jalpha, jscreen). When the call prints
([`.jst_print_on()`](https://jma61.github.io/jstats/reference/dot-jst_print_on.md)),
the body runs as it is. When it does not, its standard output goes to a
null file (every table and title is written with
[`cat()`](https://rdrr.io/r/base/cat.html), and the stdout emitter's
prose with it) and its messages are muffled (every note goes through
[`message()`](https://rdrr.io/r/base/message.html)), while warnings and
errors pass: a warning is a condition the handler leaves alone, and an
error unwinds through the sink's `on.exit`, so both show as they always
have. The body's own [`return()`](https://rdrr.io/r/base/function.html)
calls, [`on.exit()`](https://rdrr.io/r/base/on.exit.html) calls,
[`sys.call()`](https://rdrr.io/r/base/sys.parent.html) and
[`match.call()`](https://rdrr.io/r/base/match.call.html) work as before:
the body is a promise evaluated in the function's own frame. The value
is the body's, visible or not as the body left it.

## Usage

``` r
.jst_output_scope(print, body)
```

## Arguments

- print:

  The call's `print` argument, already checked.

- body:

  The function's body, braced.

## Value

The body's value.
