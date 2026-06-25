# Descriptive statistics for one or more variables

Computes basic descriptive statistics (N, non-missing, min, max, mean,
SD) for one or more variables in a data frame. Prints a formatted table
and invisibly returns the underlying results as a data frame.

## Usage

``` r
jdesc(
  data,
  ...,
  by = NULL,
  subset = NULL,
  variable.id = NULL,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  value.id = NULL,
  case.processing.detail = NULL,
  digits = NULL
)
```

## Arguments

- data:

  A data frame, or a numeric vector.

- ...:

  Unquoted variable names within `data` (ignored if data is a vector).

- by:

  An optional unquoted grouping variable name. When provided,
  descriptives are computed separately for each group, with a separate
  titled table per dependent variable.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows each variable's label in place of its name (in the descriptives
  table; for grouped output, as the per-variable caption and the
  grouping-variable column header) – best for short labels; `"legend"`
  and `"legend.bottom"` keep names and print a label legend after the
  table. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- numeric:

  Optional character vector of variable names to treat as continuous for
  this call (the per-call counterpart of
  [`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md)).
  Its only effect in `jdesc()` is to suppress the structural "seems
  categorical" descriptive caution for those variables; the descriptives
  themselves are computed the same way regardless.

- categorical:

  Not supported by `jdesc()` yet. `jdesc()` always computes numeric
  descriptives; supplying `categorical` raises an error pointing to
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md) for a
  categorical summary. (How `jdesc()` should handle an
  asserted-categorical variable is a parked design decision.)

- count:

  Optional character vector of variable names to treat as counts for
  this call (the per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)). A
  count is numeric-like here, so it behaves like `numeric`: it
  suppresses the "seems categorical" caution for those variables.

- value.id:

  Character or NULL. Value-label display mode for the grouped
  descriptive headers (the `by`-group rows): `"both"` (`"code: label"`),
  `"values"` (bare code), or `"labels"` (the label, degrading to the
  bare code where a code has none). `"legend"` and `"legend.bottom"`
  keep the bare code in the table and print a value-label legend after
  it (`"legend"` per-table, `"legend.bottom"` consolidated where
  multiple tables are produced). A no-op for grouping variables with no
  value labels, and for ungrouped calls. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `value.id` setting. Not a logical.

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

Invisibly returns a list of class `jst_desc` containing: `descriptives`
(data frame of statistics, or NULL for grouped output), and
`sample_info` (pipeline and missing data counts). Also prints a
formatted table to the console.

## Details

Output is structured consistently with
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md): a red
title is printed first, followed by a block showing the type and
variable label (or "None" if no label is present) for each variable,
then a single blank line before the table. For multiple variables, one
type/label entry is printed per variable before the shared table.

Summarizes numeric, haven-labelled, logical, numeric-coded factor, and
numeric-looking character variables. Variables that cannot be summarized
— text factors, text character variables, and date/time variables — are
skipped with a warning directing the user to
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)
(date/time variables are not supported here). When every requested
variable is unsummarizable, jdesc() stops with an error. Also accepts a
simple numeric vector. Supports grouped descriptives via the `by`
parameter.

Haven-labelled variables are reported as `haven_labelled (Categorical)`
in the type line; the uninformative `vctrs_vctr` class is suppressed.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jdesc(community, Age)
#> Descriptive Statistics
#> 
#> Variable  Total  Non_missing  Min  Max   Mean     SD
#> --------  -----  -----------  ---  ---  -----  -----
#> Age         100          100   18   71  40.66  11.68
#> 
jdesc(community, Income, Age, WellbeingScore)
#> Descriptive Statistics
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        100
#>     Remaining N         —        100
#> 
#> ────────────────────────────────────
#> 
#> 
#> Variable        Total  Non_missing    Min    Max       Mean         SD
#> --------------  -----  -----------  -----  -----  ---------  ---------
#> Income            100           94  14000  91000  47414.894  20145.391
#> Age               100          100     18     71     40.660     11.680
#> WellbeingScore    100          100     27     77     50.600     11.411
#> 
jdesc(community, WellbeingScore, by = Volunteer)
#> Descriptive Statistics by Volunteer (2 levels)
#> 
#> WellbeingScore
#> 
#> Volunteer   N  Min  Max    Mean      SD
#> ---------  --  ---  ---  ------  ------
#> 0: No      58   27   70  46.431  10.318
#> 1: Yes     42   32   77  56.357  10.385
#> 
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jdesc(Age)
#> Descriptive Statistics
#> Using default data frame: community
#> 
#> Variable  Total  Non_missing  Min  Max   Mean     SD
#> --------  -----  -----------  ---  ---  -----  -----
#> Age         100          100   18   71  40.66  11.68
#> 
jdesc(Income, Age, WellbeingScore)
#> Descriptive Statistics
#> Using default data frame: community
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        100
#>     Remaining N         —        100
#> 
#> ────────────────────────────────────
#> 
#> 
#> Variable        Total  Non_missing    Min    Max       Mean         SD
#> --------------  -----  -----------  -----  -----  ---------  ---------
#> Income            100           94  14000  91000  47414.894  20145.391
#> Age               100          100     18     71     40.660     11.680
#> WellbeingScore    100          100     27     77     50.600     11.411
#> 
jdesc(WellbeingScore, by = Volunteer)
#> Descriptive Statistics by Volunteer (2 levels)
#> Using default data frame: community
#> 
#> WellbeingScore
#> 
#> Volunteer   N  Min  Max    Mean      SD
#> ---------  --  ---  ---  ------  ------
#> 0: No      58   27   70  46.431  10.318
#> 1: Yes     42   32   77  56.357  10.385
#> 
#> 

# With a vector directly
jdesc(community$Age)
#> Descriptive Statistics
#> 
#> Variable  Total  Non_missing  Min  Max   Mean     SD
#> --------  -----  -----------  ---  ---  -----  -----
#> Age         100          100   18   71  40.66  11.68
#> 
```
