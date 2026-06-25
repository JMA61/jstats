# Internal: normalize a path for display in user-facing messages

`winslash = "/"` forces forward slashes (avoiding the Windows
backslash/forward-slash mix that arises when paths from
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) etc. are joined with
[`file.path()`](https://rdrr.io/r/base/file.path.html) output).
`mustWork = FALSE` allows the call to succeed for paths that do not yet
exist (relevant for jsave's pre-write context). Falls back to the input
unchanged on any error.

## Usage

``` r
.jst_norm_path(p)
```
