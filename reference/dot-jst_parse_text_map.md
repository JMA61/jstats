# Internal helper: parse a text-map string into a list of rules

The text-aware sibling of
[`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md),
used by
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md).
Parses a map string of the form `"Bail=1; Parole=2; Remand=3"` – words
on the left, numbers on the right – and returns the SAME list shape
[`.jst_parse_map()`](https://jma61.github.io/jstats/reference/dot-jst_parse_map.md)
returns, with `old_vals` character rather than numeric, so the
convention gate, the tag canonicalization, and the cross-convention
error consume one structure from either parser.

## Usage

``` r
.jst_parse_text_map(map_str)
```

## Arguments

- map_str:

  Character string giving the encoding map, e.g.
  `"Bail=1; Parole=2; Remand=3; else=NA"`.

## Value

Invisibly, a list with components:

- mappings:

  List of lists; each inner list has `old_vals` (character vector; the
  empty string for the blank rule), `new_val` (single numeric;
  `NA_real_` for system-NA and tagged-NA rules), and `tagged` (NULL, or
  a single lowercase letter).

- else_action:

  Character: `"na"`, `"copy"`, or `"tagged"`.

- else_tag:

  NULL, or a single lowercase letter when `else_action` is `"tagged"`.

- else_explicit:

  Logical: TRUE if the user wrote an explicit else clause.

- na_rule:

  NULL, or a list with `new_val` and `tagged`, populated by the NA /
  System / SYSMIS aliases.

## Details

Differences from the numeric parser, all of them consequences of the
left-hand side being text:

- Splitting is quote-aware, so a quoted word may contain `;`, `=`, or a
  comma.

- Three reserved unquoted left-hand words: `NA` (with its `System` /
  `SYSMIS` aliases) names plain-NA cells, `else` opens the else clause,
  and `blank` names blank cells. Quoting any of them makes it a literal
  data word.

- `blank` canonicalizes to the empty string, the form a blank cell takes
  once outer whitespace is trimmed, so a blank rule is an ordinary
  mapping and needs no separate component. A quoted empty string is
  accepted as a quiet synonym. At most one blank rule is allowed.

- An else-only map is legal (`map = "else=NA"` is the one-line repair
  for a column of numbers stored as text mixed with words); the numeric
  parser refuses one.
