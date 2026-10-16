# Internal: the full path of a shipped example file

Internal: the full path of a shipped example file

## Usage

``` r
.jst_extdata_path(name, stem = FALSE)
```

## Arguments

- name:

  A file name, with its extension; or, with `stem = TRUE`, a name
  without one.

- stem:

  Logical: match `name` against the files' names without their
  extensions (the loadable extensions only).

## Value

Character vector of full paths – one, none, or (by stem) several.
