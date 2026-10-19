# Internal helper: was an argument given a value?

[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md) and
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) refuse
`categorical =` whatever it names, so they need only to know whether it
was given – read here without evaluating a bare name (Fix Slate 23,
Session 377: `categorical = Environment2` had stopped with R's own
"object 'Environment2' not found" ahead of the refusal). A NULL, typed
or held by a name, is not a value.

## Usage

``` r
.jst_arg_given(sub, env)
```

## Arguments

- sub:

  The argument, unevaluated.

- env:

  The caller's environment.

## Value

Logical(1).
