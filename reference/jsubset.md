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
`jsubset(on)` afterward (or `jsubset(d, off)` and `jsubset(d, on)` for a
named dataset). This matches the SPSS FILTER / USE ALL convention.

Expressions use standard R logical operators: `==`, `!=`, `<`, `<=`,
`>`, `>=`, `&` (and), `|` (or), `!` (not),
[`xor()`](https://rdrr.io/r/base/Logic.html), and `%in%`. Two habits
carried over from commercial statistical software are caught with an
error that shows the corrected form: a single `=` where `==` was meant,
and the words `AND` / `OR` / `NOT` used as operators. Not every spelling
can be caught, because R's own parser reads the call before jstats does:
`jsubset(Gender = 1)`, `(Gender = 1) & (Age < 40)` and `NOT(Age < 40)`
are all shown their corrected form, but a keyword between two
conditions, `Age < 40 AND Gender == 1`, is refused by R itself with a
parser message ("unexpected symbol") that jstats cannot replace. The
same checks run on the `subset =` input of the analysis functions. See
the translation table below.

The expression must give one TRUE or FALSE for every row of the dataset.
`jsubset()` runs it once when set and refuses anything else – a single
value (`TRUE`, or an aggregate such as `mean(Score) > 5`), numbers,
text, or the wrong number of values – with an error that shows a
corrected form. The same check runs when the filter is applied, so a
filter that was valid when set but has since stopped matching the
dataset stops the analysis rather than running on the wrong rows; that
error names both ways out.

A filter normally names only columns of the data frame, and such a
filter can never fall out of step with the data. A filter may also refer
to an object in your workspace, such as a cutoff (`Age < cutoff`) or a
set of codes (`Region %in% keep_regions`). If you compute a keep/drop
indicator separately, add it to the data frame as a column and filter on
that column (`clinic$Keep <- clinic$Stress > 3`, then
`jsubset(clinic, Keep == TRUE)`). A separate object holding one value
per row stops matching the data frame if rows are later added or
removed, and every analysis of that data frame then stops until the
filter is set aside.

## Usage

``` r
jsubset(data, expr, clear.all = FALSE, ...)
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

  Each acts on the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  dataset when `data` is omitted (`jsubset(off)`, `jsubset(NULL)`), or
  on the named dataset when it is given (`jsubset(d, off)`,
  `jsubset(d, NULL)`). With no default set, `jsubset(NULL)` clears the
  one dataset that carries a setting, and asks you to name one when
  several do. To clear every dataset's setting at once, use
  `clear.all = TRUE`. If `expr` and `data` are both omitted, prints the
  current jsubset status.

- clear.all:

  Logical. If `TRUE`, clears the jsubset setting on every dataset; use
  on its own, `jsubset(clear.all = TRUE)`. This is the same grammar as
  the registration functions
  ([`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md),
  [`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md),
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md),
  [`jlikert()`](https://jma61.github.io/jstats/reference/jlikert.md)):
  `NULL` clears one dataset, `clear.all = TRUE` clears them all.

- ...:

  Not used for variables. Catches a condition typed with a single `=`,
  `jsubset(Gender = 1)`, so that the corrected `jsubset(Gender == 1)`
  can be shown in place of R's own "unused argument" error.

## Value

Invisibly returns `NULL`. Called for its side effect.

## Writing a filter in R

Stata already writes conditions the way R does. SPSS and SAS do not, and
their forms translate as follows:

|                           |                          |
|---------------------------|--------------------------|
| **SPSS or SAS**           | **R**                    |
| `Gender = 1`              | `Gender == 1`            |
| `Gender NE 1`             | `Gender != 1`            |
| `Age GE 40`               | `Age >= 40`              |
| `Age < 40 AND Gender = 1` | `Age < 40 & Gender == 1` |
| `Age < 40 OR Age > 60`    | `Age < 40 | Age > 60`    |
| `NOT (Age < 40)`          | `!(Age < 40)`            |
| `MISSING(Age)`            | `is.na(Age)`             |
| `ANY(Region, 1, 3, 5)`    | `Region %in% c(1, 3, 5)` |

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
jsubset(community, off)                  # Deactivate on a named dataset
#> jsubset deactivated for community.
jsubset(community, on)                   # ... and reactivate it
#> jsubset reactivated for community: Age < 40 & WellbeingScore > 50
jsubset()                                # Check status
#> jsubset active for community: Age < 40 & WellbeingScore > 50
jsubset(NULL)                            # Clear default dataset's setting
#> jsubset cleared for community (had: Age < 40 & WellbeingScore > 50).
jsubset(community, NULL)                 # Clear a named dataset's setting
#> No jsubset set for community. Nothing to clear.
jsubset(clear.all = TRUE)                # Clear every dataset's setting
#> No jsubset settings to clear.
# Not normally needed. You'd clear a default or registration only to
# undo a mistake, or -- as in this example -- to reset state for testing.
juse(NULL)
#> Default data frame cleared.
```
