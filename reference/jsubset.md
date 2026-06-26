# Set, activate, deactivate, or clear a per-dataset case-selection expression

`jsubset()` sets a persistent case-selection expression that is applied
automatically by jstats analysis functions when the default data frame
(set by [`juse()`](https://jma61.github.io/jstats/reference/juse.md)) is
in use. This is analogous to the SPSS FILTER command.

The expression is stored per dataset, so switching
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) between
datasets preserves each dataset's setting independently.

The expression applies whenever the matching dataset is used, regardless
of whether it was supplied via
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) or
specified explicitly in a function call. To bypass it temporarily
without losing it, use `jsubset(off)` before the analysis and
`jsubset(on)` afterward. This matches the SPSS FILTER / USE ALL
convention.

Expressions use standard R logical operators: `==`, `!=`, `<`, `<=`,
`>`, `>=`, `&` (AND), `|` (OR), `!` (NOT),
[`xor()`](https://rdrr.io/r/base/Logic.html) (XOR), and `%in%`. Using
`=` for equality or the SPSS-style keywords `AND`/`OR`/`NOT` will
produce a helpful error suggesting the correct R syntax.

## Usage

``` r
jsubset(data, expr)
```

## Arguments

- data:

  Optional data frame. If supplied, the expression is stored on that
  dataset specifically. If omitted, the dataset set by
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) is used.

- expr:

  A logical expression (e.g. `Age < 40 & Gender == 1`), or one of the
  following special values:

  `off`

  :   Deactivate the setting but remember the expression.

  `on`

  :   Reactivate a previously deactivated setting.

  `NULL`

  :   Clear the setting entirely (forget the expression).

  If `expr` and `data` are both omitted, prints the current jsubset
  status.

## Value

Invisibly returns `NULL`. Called for its side effect.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
juse(community)
#> Default data frame set to: community
jsubset(Age < 40)                        # Set using juse default
#> jsubset activated for community: Age < 40
jsubset(community, Age < 40)             # Explicit dataset
#> jsubset activated for community: Age < 40
jsubset(Age < 40 & WellbeingScore > 50)  # Compound condition
#> jsubset replaced for community: Age < 40 & WellbeingScore > 50 (was: Age < 40)
jsubset(off)                             # Deactivate
#> jsubset deactivated for community.
jsubset(on)                              # Reactivate
#> jsubset reactivated for community: Age < 40 & WellbeingScore > 50
jsubset()                                # Check status
#> jsubset active for community: Age < 40 & WellbeingScore > 50
jsubset(NULL)                            # Clear entirely
#> jsubset cleared for community (had: Age < 40 & WellbeingScore > 50).
# Not normally needed. You'd clear a default or registration only to
# undo a mistake, or -- as in this example -- to reset state for testing.
juse(NULL)
#> Default data frame cleared.
```
