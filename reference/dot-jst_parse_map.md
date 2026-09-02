# Internal helper: parse a recoding-map string into a structured rule list

Parses a map string of the form `"1=1; 2,3=2; 4,5=3; else=copy"` (used
by [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md))
into a list of mapping rules plus an else-action. Each rule's left-hand
side may be a single value or a comma-separated list of values; an
explicit `else=...` clause sets the fallback action. A left-hand side
may also include the system-NA aliases (`NA`, `System`, or `SYSMIS`,
case-insensitive) to target plain `NA` cells; alias tokens are split out
into the `na_rule` component rather than entering `mappings`, so
downstream consumers of `mappings` continue to see numeric old values
only.

## Usage

``` r
.jst_parse_map(map_str)
```

## Arguments

- map_str:

  Character string giving the recoding map, e.g. `"1=1; 2=0; else=NA"`
  or `"1=1; 2=0; else=.a"`.

## Value

Invisibly, a list with components:

- mappings:

  List of lists; each inner list has `old_vals` (numeric vector),
  `new_val` (single numeric; `NA_real_` for system-NA and tagged-NA
  rules), and `tagged` (NULL for numeric or system-NA rules; a single
  lowercase letter character for tagged-NA rules).

- else_action:

  Character: `"na"`, `"copy"`, or `"tagged"`.

- else_tag:

  NULL when `else_action` is `"na"` or `"copy"`; a single lowercase
  letter character when `else_action` is `"tagged"`.

- else_explicit:

  Logical: `TRUE` if the user wrote an explicit `else=...` clause,
  `FALSE` if defaulted.

- na_rule:

  `NULL` when the map does not name `NA` as an old value; otherwise a
  list with `new_val` (single numeric; `NA_real_` for system-NA and
  tagged-NA targets) and `tagged` (`NULL`, or a single lowercase letter
  for a tagged-NA target). Populated by the `NA` / `System` / `SYSMIS`
  aliases on a rule's left-hand side; at most one rule may name `NA`.

## Details

The right-hand side of each rule may be a numeric value, one of the
system-NA aliases (`System`, `NA`, or `SYSMIS`, case- insensitive), or a
Stata-style missing-value token (`.a` through `.z`). Tagged-NA tokens
are recorded in the parsed structure but not validated against the
active convention here; the caller
([`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md))
performs the convention check after parsing.

Errors with a clear message if the string is malformed.
