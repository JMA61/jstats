# Internal helper: read headings = or markers = as groups of names

A named list of variable names, bare or in quotes, a c() of either, or a
name holding names (ruling R18: a bare name that is one of the results'
variables is that variable, whatever the workspace holds; a bare name
that is not is read for the names it holds). Each element needs a name:
the heading's text, or the specific note's. NULL for an argument not
given.

## Usage

``` r
.jst_table_name_groups(sub, env, arg, vars = character(0))
```

## Arguments

- sub:

  The argument as typed
  ([`substitute()`](https://rdrr.io/r/base/substitute.html)).

- env:

  The caller's environment.

- arg:

  "headings" or "markers".

- vars:

  Character; the results' variables.

## Value

A named list of character vectors, or NULL.
