# Internal: names of datasets shipped in the package

Returns the bare names of every dataset shipped in the package's `data/`
directory (e.g. `community`, `clinic`), resolved through the package's
own namespace so a later package rename is followed automatically.
Returns `character(0)` when the package is not installed as a namespace
(e.g. when the source is merely
[`source()`](https://rdrr.io/r/base/source.html)d during development).

## Usage

``` r
.jst_package_datasets()
```

## Value

A character vector of dataset names, possibly empty.
