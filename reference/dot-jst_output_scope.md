# Internal helper: run an analysis function's body, printing or silent

Wraps the whole body of each analysis function (jdesc, jfreq, jmulti,
jt, jaov, jcrosstab, jlm, jlogistic, jcorr, jalpha, jscreen). The body's
standard output goes to a buffer of the scope's own – and on to the
Console as well when the call prints
([`.jst_print_on()`](https://jma61.github.io/jstats/reference/dot-jst_print_on.md))
– and each message it signals is recorded in its place among that
output, and muffled when the call does not print (every note goes
through [`message()`](https://rdrr.io/r/base/message.html)). Warnings
and errors pass: a warning is a condition the handler leaves alone, and
an error unwinds through the scope's `on.exit`, so both show as they
always have. The body's own
[`return()`](https://rdrr.io/r/base/function.html) calls,
[`on.exit()`](https://rdrr.io/r/base/on.exit.html) calls,
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

## Details

Session 423 (the (S422) printed-result item, ruled S423): what the call
printed – or, under `print = FALSE` or `joutput("silent")`, would have
printed – is kept on its result as the attribute `jstats_output`
([`.jst_scope_result()`](https://jma61.github.io/jstats/reference/dot-jst_scope_result.md)),
so a saved result typed at the Console, or given to
[`print()`](https://rdrr.io/r/base/print.html), shows that output again
([`.jst_print_result()`](https://jma61.github.io/jstats/reference/dot-jst_print_result.md)).
The color the output takes in the RStudio Console is decided before the
scope's buffer is opened – an open sink turns
[`.jst_use_color()`](https://jma61.github.io/jstats/reference/dot-jst_use_color.md)
off – and held for the body through `options(jstats.color =)`, put back
as the scope exits, so the Console shows the colors it always did and
the kept text carries them. A body that returns early – jdesc()'s
grouped form, jcorr()'s two-variable form – attaches through
[`.jst_scope_result()`](https://jma61.github.io/jstats/reference/dot-jst_scope_result.md)
itself, which reads the innermost scope open; a call given a single
vector returns the result of a second call, which kept its own. Before
Session 423 a call that did not print wrote its output to a null file.
