# Internal helper: remove dummy columns from an expanded formula

Drops named dummy symbols from the `+` chains
[`.jst_expand_one_dummy()`](https://jma61.github.io/jstats/reference/dot-jst_expand_one_dummy.md)
wrote, walking the parsed formula the same way that helper substituted
them (by identity, never by text), so an interaction term keeps its
shape: `x * (g_b + g_c + g_d)` with `g_b` dropped becomes
`x * (g_c + g_d)`. Used by
[`.jst_prune_absent_categories()`](https://jma61.github.io/jstats/reference/dot-jst_prune_absent_categories.md)
(Session 306), which drops the dummies of categories that have no case
in the analysis sample; that caller guarantees at least one dummy of
every block survives, so a block never empties.

## Usage

``` r
.jst_drop_formula_terms(formula, drop)
```

## Arguments

- formula:

  The expanded model formula.

- drop:

  Character vector of dummy column names to remove.

## Value

The formula with those symbols removed.
