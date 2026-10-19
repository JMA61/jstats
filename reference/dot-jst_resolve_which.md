# Internal helper: resolve the `which` argument for jplot dispatch methods

Translates the user's `which` argument into a vector of plot
identifiers. Accepts the special values `core` and `all` (resolved
against the supplied `core` and `all_plots` vectors) or an explicit
character vector of plot names. A name it does not take stops in voice
Rule A's form, the result named by the function that made it, and the
sentence of what `which` takes from
[`.jst_takes_names()`](https://jma61.github.io/jstats/reference/dot-jst_takes_names.md)
(Session 376).

## Usage

``` r
.jst_resolve_which(which, core, all_plots, class_name, explain = NULL)
```

## Arguments

- which:

  The user's `which` argument: `core`, `all`, or a character vector of
  plot names.

- core:

  Character vector of plot identifiers comprising the "core" set for
  this jplot method.

- all_plots:

  Character vector of all valid plot identifiers for this jplot method.

- class_name:

  Character. The S3 class being dispatched on; the stop names the
  function whose result it is.

- explain:

  Optional named character vector: a plot name the method draws only for
  some results of its kind, and the stop that says why, used in place of
  the plot-name stop when that name is the only one refused (jcorr()'s
  scatter plot, which needs two variables).

## Value

A character vector of plot identifiers to produce.

## Details

A plot name typed without quotes (Fix Slate 23, Session 377) is read
here, from the method's call, rather than evaluated: `which = vif` had
stopped with R's own "object 'vif' not found". A name this result has
gets ruling R18's pointer, the call with the name in quotes; a name it
does not have gets the plot-name stop, since the pointer's line would
stop on it next (ruling R23). The generic's own bare-word check leaves
`which` to this helper whenever `x` is a result, so the set read is this
result's, not every result's.
