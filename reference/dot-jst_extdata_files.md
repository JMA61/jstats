# Internal: the example files shipped in the package's inst/extdata

Session 361 (the Session 74 item's extdata half, decided S77 and S107):
the files jload() finds by name when no file of that name is on disk –
`community_spss.sav`, `community_stata.dta` and `community_excel.xlsx`.
Resolved through the package's own namespace, as
[`.jst_package_datasets()`](https://jma61.github.io/jstats/reference/dot-jst_package_datasets.md)
is, and empty when the package is not installed as a namespace.

## Usage

``` r
.jst_extdata_files()
```

## Value

A sorted character vector of file names, possibly empty.
