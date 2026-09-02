# Internal helper: canonical letter case for a tagged-NA marker

Embodies Decision 13's token case rule: marker-letter INPUT is
case-insensitive everywhere, but the case actually STORED follows the
governing convention – uppercase under "sas", lowercase otherwise.
Display always follows the stored tag, never the setting; this helper
governs minting only.

## Usage

``` r
.jst_canonical_tag(tag, convention)
```

## Arguments

- tag:

  Character vector of single tag letters, any case.

- convention:

  Single character: `"spss"`, `"stata"`, or `"sas"` (a resolved
  convention, as returned by
  [`.jst_resolve_convention()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_convention.md)).

## Value

Character vector of tag letters in the convention's canonical case.

## Details

Foundation-session machinery (S226): the mint sites (jrecode,
jdeclare_missing) adopt it at their parity-worklist touches; until then
they mint lowercase regardless of convention (the documented piecewise
lag).
