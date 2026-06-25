# One-way ANOVA (traditional or Welch method)

Runs a one-way ANOVA and prints a formatted group descriptives table
followed by an ANOVA table. By default, runs the traditional ANOVA
assuming equal variances. Optional parameters provide post-hoc tests,
effect size, Levene's test, and confidence intervals. Set welch = TRUE
for the Welch correction when equal variances cannot be assumed. Handles
haven-labelled, numeric, and factor grouping variables. For
haven-labelled variables, numeric codes are displayed alongside labels
in the group descriptives table.

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

  A formula of the form `DV ~ Group`.

- data:

  A data frame containing variables referenced in `formula`.

- welch:

  Logical. If FALSE (default), runs traditional ANOVA. If TRUE, runs
  Welch's ANOVA (does not assume equal variances).

- posthoc:

  Logical or NULL. If TRUE, prints Tukey HSD pairwise comparisons. Not
  available when welch = TRUE. If NULL (default), defers to
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
  not affect other function calls.

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
  level default.

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
`df2`, `p`, `eta_squared`, `n`, and `sample_info` (pipeline and missing
data counts).

## Details

A red title identifying the test type is printed first, followed by
variable labels (if present), then the results tables.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jaov(WellbeingScore ~ Region, data = community)
#> One-Way ANOVA
#> Group Descriptives: WellbeingScore by Region
#> Group      N    Mean      SD  95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  26  52.038  12.379        47.038        57.038
#> 2: South  19  49.737  12.922        43.509        55.965
#> 3: East   28  52.607   9.437        48.948        56.267
#> 4: West   27  47.741  11.175        43.320        52.162
#> 
#> ANOVA: WellbeingScore by Region
#> Source    df  Sum of Squares  Mean Square      F  p   
#> --------  --  --------------  -----------  -----  ----
#> Region     3          401.49      133.830  1.029  .383
#> Residual  96        12488.51      130.089             
#> Total     99        12890.00                          
#> 
#> Eta-squared: 0.031 
#> 
jaov(WellbeingScore ~ Region, data = community, welch = TRUE)
#> Welch's One-Way ANOVA
#> Group Descriptives: WellbeingScore by Region
#> Group      N    Mean      SD  95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  26  52.038  12.379        47.038        57.038
#> 2: South  19  49.737  12.922        43.509        55.965
#> 3: East   28  52.607   9.437        48.948        56.267
#> 4: West   27  47.741  11.175        43.320        52.162
#> 
#> Welch's ANOVA: WellbeingScore by Region
#>     F  df1   df2  p   
#> -----  ---  ----  ----
#> 1.116    3  49.6  .351
#> 
#> Note: Sum of Squares and Mean Squares are not available for Welch's ANOVA.
#> To obtain these, run jaov() without welch = TRUE.
#> 
#> Eta-squared: 0.031 
#> (Note: Eta-squared is calculated from the traditional SS decomposition.)
#> 
jaov(WellbeingScore ~ Region, data = community, full = TRUE)
#> One-Way ANOVA
#> Levene's Test for Homogeneity of Variance
#>     F  df1  df2  p   
#> -----  ---  ---  ----
#> 1.107    3   96  .350
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N    Mean      SD  95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  26  52.038  12.379        47.038        57.038
#> 2: South  19  49.737  12.922        43.509        55.965
#> 3: East   28  52.607   9.437        48.948        56.267
#> 4: West   27  47.741  11.175        43.320        52.162
#> 
#> ANOVA: WellbeingScore by Region
#> Source    df  Sum of Squares  Mean Square      F  p   
#> --------  --  --------------  -----------  -----  ----
#> Region     3          401.49      133.830  1.029  .383
#> Residual  96        12488.51      130.089             
#> Total     99        12890.00                          
#> 
#> Eta-squared: 0.031 
#> 
#> Tukey HSD Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper  p (adjusted)
#> -----------  ---------------  ------------  ------------  ------------
#> South-North           -2.302       -11.302         6.699  .909        
#> East-North             0.569        -7.553         8.691  .998        
#> West-North            -4.298       -12.492         3.896  .520        
#> East-South             2.870        -5.993        11.734  .832        
#> West-South            -1.996       -10.926         6.934  .937        
#> West-East             -4.866       -12.910         3.177  .394        
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jaov(WellbeingScore ~ Region)
#> One-Way ANOVA
#> Using default data frame: community
#> Group Descriptives: WellbeingScore by Region
#> Group      N    Mean      SD  95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  26  52.038  12.379        47.038        57.038
#> 2: South  19  49.737  12.922        43.509        55.965
#> 3: East   28  52.607   9.437        48.948        56.267
#> 4: West   27  47.741  11.175        43.320        52.162
#> 
#> ANOVA: WellbeingScore by Region
#> Source    df  Sum of Squares  Mean Square      F  p   
#> --------  --  --------------  -----------  -----  ----
#> Region     3          401.49      133.830  1.029  .383
#> Residual  96        12488.51      130.089             
#> Total     99        12890.00                          
#> 
#> Eta-squared: 0.031 
#> 
jaov(WellbeingScore ~ Region, full = TRUE)
#> One-Way ANOVA
#> Using default data frame: community
#> Levene's Test for Homogeneity of Variance
#>     F  df1  df2  p   
#> -----  ---  ---  ----
#> 1.107    3   96  .350
#> 
#> Group Descriptives: WellbeingScore by Region
#> Group      N    Mean      SD  95% CI Lower  95% CI Upper
#> --------  --  ------  ------  ------------  ------------
#> 1: North  26  52.038  12.379        47.038        57.038
#> 2: South  19  49.737  12.922        43.509        55.965
#> 3: East   28  52.607   9.437        48.948        56.267
#> 4: West   27  47.741  11.175        43.320        52.162
#> 
#> ANOVA: WellbeingScore by Region
#> Source    df  Sum of Squares  Mean Square      F  p   
#> --------  --  --------------  -----------  -----  ----
#> Region     3          401.49      133.830  1.029  .383
#> Residual  96        12488.51      130.089             
#> Total     99        12890.00                          
#> 
#> Eta-squared: 0.031 
#> 
#> Tukey HSD Post-Hoc Comparisons
#> Comparison   Mean Difference  95% CI Lower  95% CI Upper  p (adjusted)
#> -----------  ---------------  ------------  ------------  ------------
#> South-North           -2.302       -11.302         6.699  .909        
#> East-North             0.569        -7.553         8.691  .998        
#> West-North            -4.298       -12.492         3.896  .520        
#> East-South             2.870        -5.993        11.734  .832        
#> West-South            -1.996       -10.926         6.934  .937        
#> West-East             -4.866       -12.910         3.177  .394        
#> 
```
