# One-way ANOVA (traditional or Welch method)

Runs a one-way ANOVA and prints a formatted group descriptives table
followed by an ANOVA table. By default, runs the traditional ANOVA
assuming equal variances. Optional parameters provide post-hoc tests,
effect size, Levene's test, and confidence intervals. Set welch = TRUE
for the Welch correction when equal variances cannot be assumed; its
post-hoc test is Games-Howell. Handles haven-labelled, numeric, and
factor grouping variables. For haven-labelled variables, numeric codes
are displayed alongside labels in the group descriptives table.

## Usage

``` r
jaov(
  formula,
  data,
  welch = FALSE,
  posthoc = NULL,
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
  `log(DV)` is computed automatically: the tests and the descriptive
  output all use the transformed values.

- data:

  A data frame containing variables referenced in `formula`.

- welch:

  Logical. If FALSE (default), runs traditional ANOVA. If TRUE, runs
  Welch's ANOVA (does not assume equal variances). Welch's F is not a
  ratio of two mean squares, so its table shows F, df1, df2 and p: Sum
  of Squares and Mean Square belong to the traditional ANOVA table and
  are not applicable to Welch's test. Welch's ANOVA needs at least 2
  cases in every group.

- posthoc:

  Logical or NULL. If TRUE, prints pairwise comparisons of the group
  means: Tukey HSD for the traditional ANOVA, and Games-Howell when
  welch = TRUE. Games-Howell does not assume equal variances: each
  comparison uses the two groups' own variances and its own degrees of
  freedom, shown in a df column, and the p-values and confidence
  intervals are adjusted for the number of groups through the
  studentized range distribution, as Tukey's are. Commercial statistical
  software offers the same test for unequal variances (Games-Howell in
  SPSS's ONEWAY post-hoc tests). If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- effect.size:

  Logical or NULL. If TRUE, prints eta-squared. If NULL (default),
  defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- levene:

  Logical or NULL. If TRUE, prints Levene's test for homogeneity of
  variance. If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- ci:

  Logical or NULL. If TRUE, adds 95% confidence intervals to the group
  descriptives table. If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls. Written in R syntax and checked the
  way [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  checks a filter: `subset = NOT(Age < 40)`, for example, is refused
  with the corrected `subset = !(Age < 40)` shown (see
  [`jsubset`](https://jma61.github.io/jstats/reference/jsubset.md) for a
  translation table).

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows the DV and grouping-variable labels wherever the variable name
  appears (table captions and the ANOVA Source row; group levels follow
  the value.id mode) – best for short labels;
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
  level default. The Case Processing table itself prints only when a
  filter or listwise deletion excluded cases; otherwise a one-line N
  statement takes its place. See
  [`?joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  (`case.processing`).

- full:

  Logical. If TRUE, turns on posthoc, effect.size, levene, and ci all at
  once. Does not override explicit FALSE values.

- digits:

  Integer or NULL. Number of decimal places for continuous statistics in
  the output tables (range 0-7; `digits = 0` prints whole numbers with
  no trailing decimal point). Does not affect p-values, percentages, or
  integer quantities (counts, N, degrees of freedom), which keep their
  own fixed conventions. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `digits` setting (default 3).

## Value

Invisibly returns a list of class `jst_anova` containing: `model` (the
`aov` or `oneway.test` object), `model_frame` (the analysis data frame
used for plotting), `test_type`, `formula`, `descriptives`, `f`, `df1`,
`df2`, `p`, `eta_squared`, `n`, `sample_info` (pipeline and missing data
counts), and `posthoc` (the pairwise comparisons as an unrounded data
frame, with `test` naming the method; `NULL` when post-hoc tests were
not requested).

## Details

A red title identifying the test type is printed first, followed by
variable labels (if present), then the results tables.

A transformed outcome or grouping term in `formula` – `log(x)` and the
like – is computed once on the analysis data and used by the F test,
Levene's test, the post hoc comparisons, and the descriptives, so they
all describe the same values. The transforms supported inline, and those
that must be created as a column first, are as documented for
[`jlm`](https://jma61.github.io/jstats/reference/jlm.md). A value or
vector from your workspace may be named inside a computed term, as in
[`lm()`](https://rdrr.io/r/stats/lm.html): `I(x > cutoff)` with
`cutoff <- 10`. A data frame may not: write `y ~ x` with
`data = MyData`, not `MyData$y ~ MyData$x`. A vector used value by value
with the data, as in `I(x * w)`, must hold one value for each case –
each row of `data` left after filtering – where
[`lm()`](https://rdrr.io/r/stats/lm.html) would recycle a shorter one; a
set used with `%in%` may have any length.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jaov(WellbeingScore ~ Region, data = community)
#> One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 
jaov(WellbeingScore ~ Region, data = community, full = TRUE)
#> One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Levene's Test for Homogeneity of Variance
#>   F    df1  df2    p
#> -----  ---  ---  ----
#> 1.751   3    99  .162
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 
#> Tukey HSD Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper  p (adjusted)
#> -----------  ---------------  ------------  ------------  ------------
#> South-North       -4.813         -13.708        4.082          .494
#> East-North        -2.027          -9.964        5.910          .909
#> West-North        -2.163         -10.532        6.206          .906
#> East-South         2.785          -5.862       11.433          .834
#> West-South         2.650          -6.395       11.695          .870
#> West-East         -0.135          -8.240        7.969         1.000
#> 

# Checking the equal-variances assumption: Levene's test
jaov(WellbeingScore ~ Region, data = community, levene = TRUE)
#> One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Levene's Test for Homogeneity of Variance
#>   F    df1  df2    p
#> -----  ---  ---  ----
#> 1.751   3    99  .162
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 

# Pairwise comparisons after the traditional ANOVA: Tukey HSD
jaov(WellbeingScore ~ Region, data = community, posthoc = TRUE)
#> One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 
#> Tukey HSD Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper  p (adjusted)
#> -----------  ---------------  ------------  ------------  ------------
#> South-North       -4.813         -13.708        4.082          .494
#> East-North        -2.027          -9.964        5.910          .909
#> West-North        -2.163         -10.532        6.206          .906
#> East-South         2.785          -5.862       11.433          .834
#> West-South         2.650          -6.395       11.695          .870
#> West-East         -0.135          -8.240        7.969         1.000
#> 

# When equal variances cannot be assumed: Welch's ANOVA
jaov(WellbeingScore ~ Region, data = community, welch = TRUE)
#> Welch's One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> Welch's ANOVA: WellbeingScore by Region
#>   F    df1   df2    p
#> -----  ---  ----  ----
#> 0.559   3   50.3  .645
#> 
#> Note: Sum of Squares and Mean Square are not applicable to Welch's ANOVA.
#> For the standard ANOVA table, run jaov() without welch = TRUE.
#> 
#> Eta-squared: 0.020
#> (Note: Eta-squared is calculated from the traditional SS decomposition.)
#> 

# Pairwise comparisons after Welch's ANOVA: Games-Howell
jaov(WellbeingScore ~ Region, data = community, welch = TRUE,
     posthoc = TRUE)
#> Welch's One-Way ANOVA
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> Welch's ANOVA: WellbeingScore by Region
#>   F    df1   df2    p
#> -----  ---  ----  ----
#> 0.559   3   50.3  .645
#> 
#> Note: Sum of Squares and Mean Square are not applicable to Welch's ANOVA.
#> For the standard ANOVA table, run jaov() without welch = TRUE.
#> 
#> Eta-squared: 0.020
#> (Note: Eta-squared is calculated from the traditional SS decomposition.)
#> 
#> Games-Howell Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper   df   p (adjusted)
#> -----------  ---------------  ------------  ------------  ----  ------------
#> South-North       -4.813         -15.196        5.570     31.8       .597
#> East-North        -2.027          -9.038        4.983     54.6       .869
#> West-North        -2.163         -10.370        6.044     47.3       .896
#> East-South         2.785          -7.404       12.975     30.1       .879
#> West-South         2.650          -8.304       13.604     36.2       .914
#> West-East         -0.135          -8.070        7.799     46.7      1.000
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jaov(WellbeingScore ~ Region)
#> One-Way ANOVA
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 
jaov(WellbeingScore ~ Region, full = TRUE)
#> One-Way ANOVA
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Levene's Test for Homogeneity of Variance
#>   F    df1  df2    p
#> -----  ---  ---  ----
#> 1.751   3    99  .162
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N   Mean     SD    95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  27  52.963  10.147     48.949        56.977
#> 2: South  20  48.150  14.741     41.251        55.049
#> 3: East   31  50.935   9.936     47.291        54.580
#> 4: West   25  50.800  11.923     45.878        55.722
#> 
#> ANOVA: WellbeingScore by Region
#> Source     df  Sum of Squares  Mean Square    F      p
#> --------  ---  --------------  -----------  -----  ----
#> Region      3       266.441       88.814    0.667  .574
#> Residual   99     13179.384      133.125
#> Total     102     13445.825
#> 
#> Eta-squared: 0.020
#> 
#> Tukey HSD Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper  p (adjusted)
#> -----------  ---------------  ------------  ------------  ------------
#> South-North       -4.813         -13.708        4.082          .494
#> East-North        -2.027          -9.964        5.910          .909
#> West-North        -2.163         -10.532        6.206          .906
#> East-South         2.785          -5.862       11.433          .834
#> West-South         2.650          -6.395       11.695          .870
#> West-East         -0.135          -8.240        7.969         1.000
#> 
```
