# Internal helper: raise a standardized argument-validation error

Builds and signals a stop() in the package house voice: (): must be The
fn prefix names the user-facing function so the message identifies its
origin even though the package signals errors with call. = FALSE (which
suppresses R's automatic call context). Supply either a freeform
requirement string, or a character vector of allowed values via choices
to get a standardized "one of:" enumeration with consistent
double-quoting.

## Usage

``` r
.jst_stop_arg(fn = NULL, arg, requirement = NULL, choices = NULL)
```

## Arguments

- fn:

  The user-facing function name, without parentheses (e.g. "jcorr").

- arg:

  The offending argument's name (e.g. "method").

- requirement:

  A string completing " must be ..."; include the trailing period.
  Ignored when choices is supplied.

- choices:

  Optional character vector of allowed values; renders as a
  double-quoted comma-separated list introduced by "one of:".

## Value

Never returns; always signals an error.
