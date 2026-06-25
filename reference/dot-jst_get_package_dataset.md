# Internal: materialise a package-shipped dataset by name

Backs jload's package-data fallback. When a bare name passed to
[`jload()`](https://jma61.github.io/jstats/reference/jload.md) matches
no file on disk, jload calls this to look for a dataset of that name
shipped in the package's `data/` directory (e.g. `jload("community")`).
Returns the dataset as an already-evaluated data frame – forcing the
lazy-load promise so the caller can
[`assign()`](https://rdrr.io/r/base/assign.html) a materialised object
into the workspace (the Data pane), not a promise that the IDE parks
under Values until forced.

## Usage

``` r
.jst_get_package_dataset(name)
```

## Arguments

- name:

  Character(1). The bare dataset name requested.

## Value

A data frame, or `NULL`.

## Details

Resolves the package by its own namespace, so it follows a later package
rename automatically. Returns `NULL` – so jload falls through to its
usual not-found error – when the package is not installed as a namespace
(e.g. when the source is merely
[`source()`](https://rdrr.io/r/base/source.html)d during development),
when no shipped dataset of that name exists, or when the named object is
not a data frame.
