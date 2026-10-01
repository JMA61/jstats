# Internal helper: the names an expression reads as values

Walks a formula term or a filter condition and returns, in order of
first appearance, each name it reads as a value – the names
[`eval()`](https://rdrr.io/r/base/eval.html) would look up. A call's
function position is not walked. The name after `$` or `@` is a
component name, not a lookup, so only the object before it is collected:
`d$Income` reads `d`, and `params$cutoff` reads `params`. A namespaced
reference (`pkg::name`) and an inline function definition are opaque.
[`all.vars()`](https://rdrr.io/r/base/allnames.html) also lists the
component after `$`, which is why the constant and data-frame lookups
use this instead. (Session 323.)

## Usage

``` r
.jst_expr_symbols(e)
```

## Arguments

- e:

  A language object.

## Value

Character vector of names, unique, in walk order.
