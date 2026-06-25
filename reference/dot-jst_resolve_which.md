# Internal helper: resolve the `which` argument for jplot dispatch methods

Translates the user's `which` argument into a vector of plot
identifiers. Accepts the special values `core` and `all` (resolved
against the supplied `core` and `all_plots` vectors) or an explicit
character vector of plot names. Errors with a clear message listing the
valid options if any name in `which` isn't recognized.

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

  Character. The S3 class being dispatched on, used in the error
  message.

## Value

A character vector of plot identifiers to produce.
