# Internal: search for a file without extension across supported formats

Internal: search for a file without extension across supported formats

## Usage

``` r
.jst_search_no_extension(
  basename_no_ext,
  has_dir,
  exts = c("sav", "dta", "csv", "rds", "sas7bdat", "xpt", "xlsx", "xls")
)
```

## Arguments

- basename_no_ext:

  The stem to search for (no extension).

- has_dir:

  Logical. Does the stem carry a directory component?

- exts:

  Character vector of extensions to try, without the dot. Defaults to
  the eight loadable formats. jload also calls this with
  `c("rdata", "rda")` to detect an .RData file sitting where a loadable
  one was expected, so the two searches share one set of directory
  rules.
