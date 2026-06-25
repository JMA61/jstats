# Cronbach's Alpha Reliability Analysis

Computes Cronbach's alpha and prints SPSS-style reliability output
including a case processing summary, overall alpha, item statistics, and
item-total statistics with alpha-if-item-deleted. Built from scratch
with no external package dependencies beyond base R. Handles
haven-labelled variables automatically. Detects potentially
reverse-coded or misfit items.

## Usage

``` r
jalpha(
  data,
  ...,
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  case.processing.detail = NULL,
  digits = NULL
)
```

## Arguments

- data:

  A data frame.

- ...:

  Unquoted variable names (scale items) within `data`. Use colon
  notation (e.g. `Item1:Item6`) to select a range of consecutive
  columns.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows each item's label in the Item column of the Item Statistics and
  Item-Total Statistics tables (best for short labels; the returned
  tables and the reverse-coding diagnostic keep variable names);
  `"legend"`/`"legend.bottom"` keep names and print a label legend after
  the final table. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- value.id:

  Not supported by `jalpha()`. The function does not display value
  labels, so passing this argument is an error. It exists only to return
  a clear message rather than misreporting the token as a missing
  variable. Leave at NULL (default).

- case.processing.detail:

  Per-call override of the Case Processing Summary detail tier: one of
  `"none"`, `"totals"`, or `"per_code"`. `NULL` (default) uses the
  active
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  level default.

- digits:

  Integer or NULL. Number of decimal places for continuous statistics in
  the output tables (range 0-7; `digits = 0` prints whole numbers with
  no trailing decimal point). Does not affect p-values, percentages, or
  integer quantities (counts, N, degrees of freedom), which keep their
  own fixed conventions. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `digits` setting (default 3).

## Value

Invisibly returns a list of class `jst_alpha` containing: `alpha`
(Cronbach's alpha), `n_items`, `n_used`, `n_excluded`,
`item_statistics`, `item_total_statistics`, and `sample_info` (pipeline
and missing data counts). item statistics data frame, and item-total
statistics data frame.

## Details

A red "Reliability Analysis" title is printed first, followed by the
case processing summary, overall alpha, item statistics, and item-total
statistics.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jalpha(community, Environment1, Environment2, Environment3,
       Environment4, Environment5)
#> Reliability Analysis
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise        18         82
#>     Analysis N            —         82
#> 
#> Missing-data breakdown  From 100     %
#>     Environment1
#>       Missing              12     12.0
#>     Environment3
#>       Missing              12     12.0
#> 
#> ──────────────────────────────────────
#> 
#> Reliability Statistics
#> Cronbach's Alpha  N of Items
#> ----------------  ----------
#>            0.297           5
#> 
#> Item Statistics
#> Item           Mean     SD   N
#> ------------  -----  -----  --
#> Environment1  2.988  1.212  82
#> Environment2  2.780  1.228  82
#> Environment3  3.134  1.163  82
#> Environment4  3.098  1.203  82
#> Environment5  2.976  1.474  82
#> 
#> Warning: The following item(s) are negatively correlated with the rest of the scale: Environment2.
#> They may need reverse-coding, or may not belong in the scale - check the item-total table and the item wording.
#> 
#> Item-Total Statistics
#> Item          Corrected Item-Total r  Alpha if Item Deleted
#> ------------  ----------------------  ---------------------
#> Environment1                   0.505                 -0.115
#> Environment2                  -0.615                  0.749
#> Environment3                   0.536                 -0.129
#> Environment4                   0.365                  0.040
#> Environment5                   0.340                  0.012
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jalpha(Environment1, Environment2, Environment3, Environment4,
       Environment5)
#> Reliability Analysis
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise        18         82
#>     Analysis N            —         82
#> 
#> Missing-data breakdown  From 100     %
#>     Environment1
#>       Missing              12     12.0
#>     Environment3
#>       Missing              12     12.0
#> 
#> ──────────────────────────────────────
#> 
#> Reliability Statistics
#> Cronbach's Alpha  N of Items
#> ----------------  ----------
#>            0.297           5
#> 
#> Item Statistics
#> Item           Mean     SD   N
#> ------------  -----  -----  --
#> Environment1  2.988  1.212  82
#> Environment2  2.780  1.228  82
#> Environment3  3.134  1.163  82
#> Environment4  3.098  1.203  82
#> Environment5  2.976  1.474  82
#> 
#> Warning: The following item(s) are negatively correlated with the rest of the scale: Environment2.
#> They may need reverse-coding, or may not belong in the scale - check the item-total table and the item wording.
#> 
#> Item-Total Statistics
#> Item          Corrected Item-Total r  Alpha if Item Deleted
#> ------------  ----------------------  ---------------------
#> Environment1                   0.505                 -0.115
#> Environment2                  -0.615                  0.749
#> Environment3                   0.536                 -0.129
#> Environment4                   0.365                  0.040
#> Environment5                   0.340                  0.012
#> 
```
