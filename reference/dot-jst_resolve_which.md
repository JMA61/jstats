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
.jst_resolve_which(which, core, all_plots, class_name)
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

## Value

A character vector of plot identifiers to produce.
