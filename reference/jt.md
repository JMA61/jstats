# Independent samples or paired samples t-test

Runs a t-test and prints formatted group descriptives and test results.
By default, runs the traditional Student's independent samples t-test
assuming equal variances. Optional parameters provide Welch's
correction, paired samples, effect size (Cohen's d), Levene's test, and
confidence interval for the mean difference. Handles haven-labelled,
numeric, and factor grouping variables. For haven-labelled variables,
numeric codes are displayed alongside labels in the group descriptives
table.

## Usage

``` r
jt(
  formula,
  data,
  paired = FALSE,
  welch = FALSE,
  effect.size = NULL,
  levene = NULL,
  ci = NULL,
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  case.processing.detail = NULL,
  full = FALSE,
  digits = NULL
)
```

## Arguments

- formula:

  A formula of the form `DV ~ Group`. A transformed term such as
  `log(DV)` is computed automatically: the test and the descriptive
  output both use the transformed values.

- data:

  A data frame containing variables referenced in `formula`.

- paired:

  Logical. If TRUE, runs a paired samples t-test. Cases are paired by
  position: the i-th case in one group is matched with the i-th case in
  the other, so the two groups must have equal sample sizes. A pair is
  dropped from the analysis when either member is missing (matching how
  commercial statistical software handles paired comparisons), and a
  note reports how many pairs were dropped. Default is FALSE.

- welch:

  Logical. If FALSE (default), runs Student's t-test (equal variances
  assumed). If TRUE, runs Welch's t-test. Ignored when paired = TRUE.

- effect.size:

  Logical or NULL. If TRUE, prints Cohen's d. If NULL (default), defers
  to [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  session setting.

- levene:

  Logical or NULL. If TRUE, prints Levene's test for homogeneity of
  variance. Ignored when paired = TRUE. If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- ci:

  Logical or NULL. If TRUE, adds 95% confidence interval for the mean
  difference. If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows the DV and grouping-variable labels in the table captions (group
  levels follow the value.id mode) – best for short labels;
  `"legend"`/`"legend.bottom"` keep names and print a label legend after
  the output. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- value.id:

  Character or NULL. Value-label display mode for the group descriptives
  rows: `"both"` (`"code: label"`), `"values"` (bare code), or
  `"labels"` (the label, degrading to the bare code where a code has
  none). `"legend"` and `"legend.bottom"` keep the bare code in the
  table and print a value-label legend after it (`"legend"` per-table,
  `"legend.bottom"` consolidated where multiple tables are produced). A
  no-op for grouping variables with no value labels. NULL (default)
  defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `value.id` setting. Not a logical.

- case.processing.detail:

  Per-call override of the Case Processing Summary detail tier: one of
  `"none"`, `"totals"`, or `"per_code"`. `NULL` (default) uses the
  active
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  level default.

- full:

  Logical. If TRUE, turns on effect.size, levene, and ci all at once.
  Does not override explicit FALSE values.

- digits:

  Integer or NULL. Number of decimal places for continuous statistics in
  the output tables (range 0-7; `digits = 0` prints whole numbers with
  no trailing decimal point). Does not affect p-values, percentages, or
  integer quantities (counts, N, degrees of freedom), which keep their
  own fixed conventions. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `digits` setting (default 3).

## Value

Invisibly returns a list of class `jst_ttest` containing: `model` (the
`t.test` result), `model_frame` (the analysis data frame used for
plotting), `test_type`, `formula`, `descriptives`, `t`, `df`, `p`,
`mean_difference`, `ci` (95% CI), `cohens_d`, `d_label`, `n`, and
`sample_info` (pipeline and missing data counts).

## Details

A red title identifying the test type is printed first, followed by
variable labels (if present), then the results tables.

A transformed outcome or grouping term in `formula` – `log(x)` and the
like – is computed once on the analysis data and used by both the t-test
and the group descriptives, so the two describe the same values. The
transforms supported inline, and those that must be created as a column
first, are as documented for
[`jlm`](https://jma61.github.io/jstats/reference/jlm.md).

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jt(WellbeingScore ~ Volunteer, data = community)
#> Independent Samples T-Test
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N    Mean      SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>      t   df  p     Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001           -7.211       -11.496        -2.925
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, data = community, welch = TRUE)
#> Welch's Independent Samples T-Test
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N    Mean      SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Welch's T-Test Results (equal variances not assumed)
#>      t     df  p     Mean Difference  95% CI Lower  95% CI Upper
#> ------  -----  ----  ---------------  ------------  ------------
#> -3.362  100.7  .001           -7.211       -11.465        -2.956
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, data = community, full = TRUE)
#> Independent Samples T-Test
#> Levene's Test for Homogeneity of Variance
#>     F  df1  df2  p   
#> -----  ---  ---  ----
#> 0.719    1  101  .399
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N    Mean      SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>      t   df  p     Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001           -7.211       -11.496        -2.925
#> 
#> Cohen's d: -0.658
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jt(WellbeingScore ~ Volunteer)
#> Independent Samples T-Test
#> Using default data frame: community
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N    Mean      SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>      t   df  p     Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001           -7.211       -11.496        -2.925
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, full = TRUE)
#> Independent Samples T-Test
#> Using default data frame: community
#> Levene's Test for Homogeneity of Variance
#>     F  df1  df2  p   
#> -----  ---  ---  ----
#> 0.719    1  101  .399
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N    Mean      SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>      t   df  p     Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001           -7.211       -11.496        -2.925
#> 
#> Cohen's d: -0.658
#> 
```
