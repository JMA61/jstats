# Internal: map a file extension to its user-facing format label

Returns the format-name parenthetical used in jload and jsave success
messages – e.g. `"Stata format"` for `.dta`, `"R native format"` for
`.rds`. Centralises the mapping so both functions stay in sync, and so
the labels can be edited in one place if the wording is later refined.

## Usage

``` r
.jst_format_label(ext)
```

## Details

Unknown extensions fall back to `<ext> format` (e.g. `"foo format"`),
which keeps the message structurally sound even if a new extension is
added without updating this helper.
