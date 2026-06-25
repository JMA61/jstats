# Internal: warn on a case-only collision between data.dir and an existing folder

On a case-insensitive filesystem (Windows, and macOS by default), a
`data.dir` such as `"Data"` silently resolves onto an existing folder of
a different case (e.g. `"data"`); saves and loads then use the existing
folder, and a teardown aimed at the configured name could remove the
wrong one. This emits a note at set time when that collision is
detected. Case-sensitive filesystems (Linux) create a distinct folder
and are not warned, so the behaviour is intentionally non-uniform across
operating systems.

## Usage

``` r
.jst_data_dir_case_warning(dir)
```

## Arguments

- dir:

  Character(1). The data.dir value just set.

## Value

Invisibly `NULL`; called for the message side effect.
