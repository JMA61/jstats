# Register variables as Likert (ordered response) items

`jlikert()` declares one or more value-labelled variables as Likert
items – ordered response scales (for example 1 = Strongly disagree
through 5 = Strongly agree). It is the ordered-scale counterpart to
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md)
(categorical),
[`jnumeric`](https://jma61.github.io/jstats/reference/jnumeric.md)
(continuous), and
[`jcount`](https://jma61.github.io/jstats/reference/jcount.md) (count):
a variable carries exactly one registered intent at a time, so
registering it as Likert clears any prior numeric, count, or dummy
registration on it.

## Usage

``` r
jlikert(data, ..., remove = FALSE, clear.all = FALSE)
```

## Arguments

- data:

  A data frame, or omitted to use the
  [`juse`](https://jma61.github.io/jstats/reference/juse.md) default.

- ...:

  One or more unquoted variable names to register, or a single `NULL` to
  clear this frame's Likert registrations (see Details).

- remove:

  Logical; if TRUE, remove the named variables' Likert registrations
  instead of adding them.

- clear.all:

  Logical; if TRUE, clear Likert registrations on every data frame.

## Value

Invisibly NULL. Called for its side effect on the session registry.

## Details

**Scope – display only.** The Likert intent refines reporting, not
analysis. It sets the variable's sub-class to "Likert" in
[`jscreen`](https://jma61.github.io/jstats/reference/jscreen.md)'s
Variable Types table, marking it as an ordered scale rather than a
generic N-category variable. It does NOT change how any analysis treats
the variable (there is no order-aware modelling), and it does not by
itself change
[`jplot`](https://jma61.github.io/jstats/reference/jplot.md) output – a
value-labelled small-range variable already plots as an ordered,
labelled bar regardless of this registration.

Like the other registration verbs, registrations are session-scoped and
keyed by data-frame name; save the frame in R format (.rds) with
[`jsave`](https://jma61.github.io/jstats/reference/jsave.md) to keep
them across sessions.

Clearing mirrors the other registration verbs:

- `jlikert(data, NULL)` – clear this frame's Likert registrations.

- `jlikert(NULL)` – clear the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  frame (or the sole frame carrying Likert registrations; if several do,
  it asks rather than clearing them all).

- `jlikert(clear.all = TRUE)` – clear every frame.

`jlikert()` with no arguments prints the current registration status.

## See also

[`jnumeric`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jcount`](https://jma61.github.io/jstats/reference/jcount.md),
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md),
[`jscreen`](https://jma61.github.io/jstats/reference/jscreen.md)

## Examples

``` r
  jlikert(community, Environment1, Environment2)  # declare two Likert items
#> Likert registration set for 'Environment1', 'Environment2' in community.
#> Note: registrations are stored for this session only.
#> To keep them across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registrations:
#>   community <- jload("community.rds")
  jscreen(community)                              # Sub-class shows "Likert"
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Source         Unique Values
#> --------------  ------------  ----------  -------------  -------------
#> RespondentID    Categorical   identifier                           103
#> Income          Numeric                                             49
#> Education       Categorical   5-category                             5
#> Age             Numeric                                             41
#> WellbeingScore  Numeric                                             41
#> Volunteer       Categorical   dichotomy                              2
#> OwnsHome        Categorical   dichotomy*                             2
#> Smoker          Categorical   dichotomy                              2
#> CommuteTime     Numeric                                             42
#> Region          Categorical   4-category                             4
#> Environment1    Categorical   Likert      User-declared              5
#> Environment2    Categorical   Likert      User-declared              5
#> Environment3    Categorical   Likert                                 5
#> Environment4    Categorical   Likert                                 5
#> Environment5    Categorical   Likert                                 5
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable      Missing  % Missing
#> ------------  -------  ---------
#> Income              6        5.8
#> Education           6        5.8
#> Smoker              5        4.9
#> Environment1       12       11.7
#> Environment3       12       11.7
#> 
  jlikert(community, Environment1, remove = TRUE) # undo one
#> Likert registration removed for 'Environment1' in community.
  jlikert(community, NULL)                        # clear the registrations
#> Likert registrations cleared for community: Environment2.
```
