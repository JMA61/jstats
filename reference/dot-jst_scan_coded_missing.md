# Internal: scan for coded missing values and report findings

Classifies findings two ways: label-only (a value label suggesting
missingness, per the package wordlist, with no formal declaration) and
suspected (a suspicious sentinel value with no metadata at all). Values
formally declared in `na_values` or `na_range` are excluded from both
classifications – declared UDMs are reported by jload's narrative
(`.jst_handle_udms`), not here.

## Usage

``` r
.jst_scan_coded_missing(df, obj_name)
```
