# Internal: get the ordered list of directories to search for data files

Resolution rules:

- If `joptions("data.dir")` is set and that folder exists, it is
  searched first.

- The working directory itself is always included as the final search
  location.

## Usage

``` r
.jst_missing_data_dir_note()
```

## Details

Internal: note for a configured-but-missing data.dir

Returns a one-line note (with a leading newline) when
`joptions(data.dir = ...)` points at a folder that does not currently
exist; otherwise returns `""`. Appended to jload's not-found errors so a
typo'd or stale `data.dir` is diagnosed where it bites rather than
surfacing as a bare "searched in working directory". Uses the same
[`dir.exists()`](https://rdrr.io/r/base/files2.html) test as
`.jst_get_search_dirs()`, so it fires exactly when the configured folder
was skipped from the search path.
