# Internal helper: does a value label suggest missingness?

Returns `TRUE` when the supplied label string, after case-folding and
whitespace trimming, matches an entry in `.jst_missing_label_wordlist`.
Returns `FALSE` for `NULL`, `NA`, non-character input, and labels that
do not match the wordlist.

## Usage

``` r
.jst_label_suggests_missing(label)
```
