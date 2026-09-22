# Internal helper: install the latest jstats into lib in a child R process

The callr hand-off jupdate() makes, factored out so a test can stand in
for it and see the library it was handed. The child never loads jstats,
so the package files are not locked (the usual cause of a failed update
on Windows). install.packages() reports every failure it meets – a
repository it cannot reach, a package it cannot find, an install that
exits non-zero – as a WARNING and returns normally, so the child
collects those warnings and returns them for the caller to act on; the
caller decides success by what is on disk afterwards. Errors propagate.
(S309)

## Usage

``` r
.jst_update_install(lib)
```

## Arguments

- lib:

  The library folder to install into.

## Value

A character vector of the warnings install.packages() raised in the
child, in order; empty when it raised none.
