# Internal: detect SPSS-form UDM-bearing columns in a data frame

Returns the names of variables whose UDM representation is SPSS-form,
i.e. the column carries `na_values` and/or `na_range` attributes (as
produced by
[`haven::labelled_spss()`](https://haven.tidyverse.org/reference/labelled_spss.html)).
Used by jsave's pre-flight check before writing to `.dta` (which has no
SPSS-UDM representation; Stata uses tagged NAs instead).

## Usage

``` r
.jst_has_spss_udm(data)
```

## Details

Walks the columns of `data` via
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
for a single source of truth on UDM representation detection. Returns
names where `representation == "spss"`.
