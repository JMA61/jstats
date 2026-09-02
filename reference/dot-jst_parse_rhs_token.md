# Internal helper: parse a map rule's right-hand side

The ONE shared right-hand-side token reader for the recode family:
[`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md)
(numeric old values, used by
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)) and
[`.jst_parse_text_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_text_map.md)
(text old values, used by
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)) both
route their RHS through it, so a new target keyword is added in one
place and both functions inherit it. Recognizes the system-NA aliases
and Stata-style missing-value tokens, and raises a helpful error on
malformed tagged-NA shapes. Returns `NULL` when the token is not a
recognized keyword, leaving the caller to fall through to its own
numeric-target path.

## Usage

``` r
.jst_parse_rhs_token(rhs_str, rule_str)
```

## Arguments

- rhs_str:

  Character. The raw right-hand side of one rule.

- rule_str:

  Character. The whole rule, quoted back in the error message so the
  user can find it in the map string.

## Value

A list with `new_val` (numeric; `NA_real_` for system-NA and tagged-NA
targets), `tagged` (`NULL`, or a single lowercase letter), `tagged_raw`
(present with `tagged`: the same letter in the case the user typed, for
quoting the call back in messages), and – for the `missing` token only –
`missing = TRUE`, a marker the caller resolves after its convention
gate; or `NULL` when the token is not recognized.

## Details

Hoisted out of
[`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md)
unchanged (Session 237); it was a local closure capturing nothing from
its enclosing frame, so both callers see identical behavior.
