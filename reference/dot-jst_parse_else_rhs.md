# Internal: a map's else rule read

else=NA (or System, SYSMIS), else=copy, or else= a marker (.a; the
letter as typed kept, S245); a marker spelled otherwise, NA(...), or any
other word stops, in the parsers' plain voice (the calling recode
re-frames it). .jst_parse_map() and .jst_parse_text_map() each held this
block (Session 386, the twin build).

## Usage

``` r
.jst_parse_else_rhs(result, rhs, ms)
```

## Arguments

- result:

  The map being parsed.

- rhs:

  Character(1): the else rule's right side.

- ms:

  The parser's marker phrasing (.jst_marker_syntax()).

## Value

The map, its else fields set.
