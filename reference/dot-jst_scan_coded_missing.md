# Internal: scan for coded missing values and report findings

Classifies findings three ways, most specific first: label-only (a value
label suggesting missingness, per the package wordlist, with no formal
declaration); convention-matched (Session 361; the Session 23 item,
Decision 5A: a value in the `missing.convention.codes` setting, found
whether or not the heuristic flags it); and suspected (a suspicious
sentinel value with no metadata at all). Values formally declared in
`na_values` or `na_range` are excluded from every classification –
declared UDMs are reported by jload's narrative (`.jst_handle_udms`),
not here.

## Usage

``` r
.jst_scan_coded_missing(df, obj_name)
```
