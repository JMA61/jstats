# Internal helper: render a parsed map back to its map-string form

Rebuilds the user's map string from the parsed structure, for the
runnable-recipe lines of the missing-token message family (Session 241):
the conflict gate re-shows the map verbatim, the cap error swaps the
missing target for a declared code, and the map-target mint note swaps a
flagged numeric target for the missing token. Token rules render as the
word missing whether or not they have been substituted yet, so the same
renderer serves pre- and post-resolution callers.

## Usage

``` r
.jst_render_map_string(
  parsed_map,
  lhs_render = NULL,
  targets_to_missing = numeric(0),
  missing_as = NULL
)
```

## Arguments

- parsed_map:

  A parsed map from
  [`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md)
  or
  [`.jst_parse_text_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_text_map.md).

- lhs_render:

  Optional function rendering one rule's `old_vals`; `NULL` renders them
  as numbers
  ([`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)'s
  side).
  [`jencode()`](https://jma61.github.io/jstats/reference/jencode.md)
  supplies `.jst_jencode_lhs_render`.

- targets_to_missing:

  Numeric vector. Plain numeric targets to render as the missing token
  instead of their value.

- missing_as:

  Optional character. When supplied, token rules render as this text
  instead of the word missing (the cap error's declared-code swap).

## Value

Character scalar: the map string, without surrounding quotes.
