# Internal helper: resolve which data frame to use when none is explicitly given

Looks up the data frame name set by
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) via the
`.jst_default_data` option, fetches the object from the specified
environment, and returns both the data frame itself and its name. The
name is needed by callers for output messages such as "(Using default
data frame: X)".

## Usage

``` r
.jst_resolve_data(envir = parent.frame())
```

## Arguments

- envir:

  Environment in which to look up the default data frame. Defaults to
  the parent frame so the caller's environment is searched.

## Value

A list with two components:

- data:

  The resolved data frame.

- name:

  Character string giving the name of the data frame.

## Details

Errors with a clear message if no default has been set, if the named
object cannot be found in the supplied environment, or if it is not a
data frame.
