# Internal: detect tagged-NA-bearing columns in a data frame

Returns the names of variables whose UDM representation is Stata-form
(Stata-style tagged missing values, e.g. `haven::tagged_na("a")`). Used
by jsave's pre-flight checks before writing to `.sav` and `.xpt`
(neither format carries tagged NAs).

## Usage

``` r
.jst_has_tagged_na(data)
```

## Details

Walks the columns of `data` via
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
for a single source of truth on UDM representation detection. Returns
names where `representation == "stata"`.
