# Internal: a map rule's right side, as the map stores it

A token (a marker, the word missing) as .jst_parse_rhs_token() read it,
else the number the parser read: new_val, tagged, tagged_raw and
missing, in that order. .jst_parse_map() and .jst_parse_text_map() each
held this block (Session 386, the twin build); each keeps its own stop
for a right side that is neither.

## Usage

``` r
.jst_map_rule_entry(rhs_parsed, new_val)
```

## Arguments

- rhs_parsed:

  The token read, or NULL.

- new_val:

  The number read (used only when rhs_parsed is NULL).

## Value

list(new_val, tagged, tagged_raw, missing).
