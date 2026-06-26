# Logistic regression with SPSS-style output

Fits a binary logistic regression using
[`stats::glm()`](https://rdrr.io/r/stats/glm.html) with
`family = binomial` and prints formatted output including an omnibus
model test, model summary statistics, and a coefficients table with odds
ratios (Exp(B)).

## Usage

``` r
jlogistic(
  formula,
  data,
  subset = NULL,
  variable.id = NULL,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  ci = NULL,
  classification = FALSE,
  diagnostics = NULL,
  ref.categories = NULL,
  full = FALSE,
  case.processing.detail = NULL,
  digits = NULL,
  ...,
  value.id = NULL
)
```

## Arguments

- formula:

  A model formula, e.g. `DV ~ IV1 + IV2`. The DV must be a binary
  variable coded 0/1.

- data:

  A data frame containing variables referenced in `formula`.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  replaces each coefficient's variable name with its label in the
  Coefficients table (factor level decoration is preserved) – best for
  short labels; `"legend"` prints a label legend just below the
  Coefficients table (at the coefficients/fit seam); `"legend.bottom"`
  prints it at the very end. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- numeric:

  Optional character vector of variable names to treat as continuous
  even if they have value labels.

- categorical:

  Optional character vector of variable names to treat as categorical
  even if they lack value labels.

- count:

  Optional character vector of independent-variable names to treat as
  counts for this call (the per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)). A
  count predictor is numeric-like, so it enters the model exactly as
  `numeric` would; the argument is provided for symmetry with the other
  analysis functions. The binary dependent variable is fixed, so naming
  it here has no effect. A variable cannot be listed in both `count` and
  `categorical`.

- ci:

  Logical or NULL. If TRUE, adds 95% confidence intervals for Exp(B). If
  NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- classification:

  Logical. If TRUE, prints a classification table showing predicted vs
  observed outcomes. Default is FALSE.

- diagnostics:

  Logical, character vector, or NULL. If TRUE, prints VIF table. If a
  character vector, `vif` is currently the only supported option. If
  NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- ref.categories:

  Logical or NULL. Per-call override for showing the
  reference-categories block (the baseline level dropped from each set
  of dummy variables). `NULL` (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `ref.categories` setting. Applies to
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) and
  `jlogistic()` only, since they are the functions that produce
  dummy-coded coefficient tables.

- full:

  Logical. If TRUE, turns on ci, classification, and diagnostics. Does
  not override explicit FALSE values.

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

- ...:

  Reserved for argument-name checking. Passing `which`, `plots`, or
  `show` will produce a helpful error suggesting `diagnostics` instead.

- value.id:

  Character or NULL. Value-label display mode for the dummy category
  rows in the Coefficients table: one of `"both"` (`"code: label"`,
  degrading to a bare code where a code has no label), `"values"` (the
  bare code), or `"labels"` (the value label, degrading to the bare code
  where none exists). The reference category folded into each grouped
  variable's header follows the same mode. `"legend"` and
  `"legend.bottom"` are not supported here: a coefficient table already
  pairs each value label with its row, so a separate legend block would
  only duplicate it. Passing either explicitly is an error; a
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  default of `"legend"` or `"legend.bottom"` is tolerated and rendered
  as `"both"`, so it does not break a bare call. Variables with no value
  labels render identically under all supported modes. NULL (default)
  defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `value.id` setting. Applies only to multi-category dummy predictors;
  continuous and single-contrast (dichotomous) predictors are
  unaffected. Not a logical.

## Value

Invisibly returns a list of class `jst_logistic` containing:

- model:

  The fitted `glm` object.

- model_type:

  Character string `logistic`.

- model_frame:

  The model frame used to fit the model.

- formula_used:

  The formula after dummy expansion.

- coefficients:

  Formatted coefficient table (data frame).

- coefficients_raw:

  Flat data frame of raw, full-precision coefficient statistics (one row
  per coefficient): `term` (machine key, shared with jlm), `b`, `SE`,
  `Wald`, `df`, `p`, `exp_b`, and `exp_ci_lower` / `exp_ci_upper`
  odds-ratio CI bounds (present regardless of the `ci` display toggle).
  Carries an `outcome` attribute.

- fit_raw:

  List of raw, full-precision model-level fit statistics: `ll_model`,
  `ll_null`, `deviance`, `null_deviance`, the omnibus likelihood-ratio
  test (`chi_sq`, `omnibus_df`, `omnibus_p`), Cox & Snell and Nagelkerke
  pseudo R-squared (`cox_snell_r2`, `nagelkerke_r2`), `aic`, and `n`.

- nagelkerke_r2:

  Nagelkerke pseudo R-squared.

- cox_snell_r2:

  Cox & Snell pseudo R-squared.

- neg2ll:

  -2 Log Likelihood.

- aic:

  Akaike Information Criterion.

- omnibus:

  Named vector: chi_square, df, p.

- n:

  Number of observations.

- predicts:

  Character string describing what the model predicts.

- dummy_coef_names:

  Names of dummy variable columns.

- ref_cats:

  Reference category descriptions.

- vif:

  Named numeric vector of VIF values, or NULL.

- sample_info:

  Pipeline and missing data counts.

## Details

The dependent variable must be coded 0/1. If it is not, the function
stops with a clear error message and suggests the appropriate
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
command.

Handles haven-labelled variables, registered dummy variables via
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md), and
the `numeric`/`categorical` overrides in the same way as
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md).

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame -- Volunteer is already coded 0/1
jlogistic(Volunteer ~ Income + Age, data = community)
#> Logistic Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise         6         94
#>     Analysis N            —         94
#> 
#> Missing-data breakdown  From 100    %
#>     Income
#>       Missing              6      6.0
#> 
#> ──────────────────────────────────────
#> 
#> 
#> Coefficients
#>                b      SE    Wald   df   p    Exp(B)
#> -----------  ------  -----  -----  --  ----  ------
#> (Intercept)  -2.543  0.925  7.565   1  .006   0.079
#> Income        0.000  0.000  4.849   1  .028   1.000
#> Age           0.023  0.020  1.351   1  .245   1.023
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p   
#> ----------  --  ----
#>      8.548   2  .014
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           119.027           0.087          0.117  125.027
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# A 1/2-coded dichotomy (Yes = 1, No = 2) must be recoded to 0/1 first
df <- community
df$OwnsHome01 <- jrecode(df, OwnsHome,
                         map = "1=1; 2=0", labels = "0=No; 1=Yes")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.
jlogistic(OwnsHome01 ~ Income + Age, data = df)
#> Logistic Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise         6         94
#>     Analysis N            —         94
#> 
#> Missing-data breakdown  From 100    %
#>     Income
#>       Missing              6      6.0
#> 
#> ──────────────────────────────────────
#> 
#> 
#> Coefficients
#>                b      SE     Wald   df    p    Exp(B)
#> -----------  ------  -----  ------  --  -----  ------
#> (Intercept)  -5.586  1.268  19.421   1  <.001   0.004
#> Income        0.000  0.000   9.186   1   .002   1.000
#> Age           0.082  0.025  10.948   1  <.001   1.086
#> 
#> Outcome: OwnsHome01
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p    
#> ----------  --  -----
#>       30.4   2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²     AIC
#> -----------------  --------------  -------------  ------
#>             99.23           0.276          0.369  105.23
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# Using juse() default
juse(community)
#> Default data frame set to: community
jlogistic(Volunteer ~ Income + Age)
#> Logistic Regression
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise         6         94
#>     Analysis N            —         94
#> 
#> Missing-data breakdown  From 100    %
#>     Income
#>       Missing              6      6.0
#> 
#> ──────────────────────────────────────
#> 
#> 
#> Coefficients
#>                b      SE    Wald   df   p    Exp(B)
#> -----------  ------  -----  -----  --  ----  ------
#> (Intercept)  -2.543  0.925  7.565   1  .006   0.079
#> Income        0.000  0.000  4.849   1  .028   1.000
#> Age           0.023  0.020  1.351   1  .245   1.023
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p   
#> ----------  --  ----
#>      8.548   2  .014
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           119.027           0.087          0.117  125.027
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# CATEGORICAL PREDICTORS
#
# Per-call: categorical = ... applies for one call only and does not
# persist.
jlogistic(Volunteer ~ Region + Age, categorical = "Region")
#> Logistic Regression
#> Using default data frame: community
#> 
#> Coefficients
#>                     b      SE    Wald   df   p    Exp(B)
#> ----------------  ------  -----  -----  --  ----  ------
#> (Intercept)       -2.144  0.901  5.662   1  .017   0.117
#> Region_South (1)   0.155  0.642  0.058   1  .809   1.168
#> Region_East (1)    0.692  0.570  1.474   1  .225   1.998
#> Region_West (1)   -0.396  0.596  0.441   1  .507   0.673
#> Age                0.041  0.020  4.474   1  .034   1.042
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p   
#> ----------  --  ----
#>      8.544   4  .074
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           127.515           0.082           0.11  137.515
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# The recommended approach for repeated analyses: register the variable
# with jdummy() before running jlogistic(). This sets categorical
# treatment persistently across subsequent analyses.
jdummy(community, Region)
#> Dummy Variable Registration
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_North
#>   Dummy variables: Region_South, Region_East, Region_West
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jlogistic(Volunteer ~ Region + Age)
#> Logistic Regression
#> Using default data frame: community
#> 
#> Coefficients
#>                     b      SE    Wald   df   p    Exp(B)
#> ----------------  ------  -----  -----  --  ----  ------
#> (Intercept)       -2.144  0.901  5.662   1  .017   0.117
#> Region_South (1)   0.155  0.642  0.058   1  .809   1.168
#> Region_East (1)    0.692  0.570  1.474   1  .225   1.998
#> Region_West (1)   -0.396  0.596  0.441   1  .507   0.673
#> Age                0.041  0.020  4.474   1  .034   1.042
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p   
#> ----------  --  ----
#>      8.544   4  .074
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           127.515           0.082           0.11  137.515
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# To choose a non-default reference category:
jdummy(community, Region, ref = "West")
#> Dummy Variable Registration
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_West
#>   Dummy variables: Region_North, Region_South, Region_East
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jlogistic(Volunteer ~ Region + Age)
#> Logistic Regression
#> Using default data frame: community
#> 
#> Coefficients
#>                     b      SE    Wald   df   p    Exp(B)
#> ----------------  ------  -----  -----  --  ----  ------
#> (Intercept)       -2.540  0.984  6.656   1  .010   0.079
#> Region_North (1)   0.396  0.596  0.441   1  .507   1.485
#> Region_South (1)   0.551  0.669  0.677   1  .410   1.734
#> Region_East (1)    1.088  0.581  3.504   1  .061   2.967
#> Age                0.041  0.020  4.474   1  .034   1.042
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p   
#> ----------  --  ----
#>      8.544   4  .074
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           127.515           0.082           0.11  137.515
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# FORCING NUMERIC TREATMENT
#
# Use numeric = ... when a labelled variable should enter as a score.
jlogistic(Volunteer ~ Age + Education, numeric = "Education")
#> Logistic Regression
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        100
#>     Auto-listwise         6         94
#>     Analysis N            —         94
#> 
#> Missing-data breakdown  From 100    %
#>     Education
#>       Missing              6      6.0
#> 
#> ──────────────────────────────────────
#> 
#> 
#> Coefficients
#>                b      SE     Wald   df    p    Exp(B)
#> -----------  ------  -----  ------  --  -----  ------
#> (Intercept)  -4.484  1.209  13.755   1  <.001   0.011
#> Age           0.042  0.022   3.654   1   .056   1.043
#> Education     0.841  0.197  18.137   1  <.001   2.318
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df  p    
#> ----------  --  -----
#>     27.586   2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²      AIC
#> -----------------  --------------  -------------  -------
#>           100.633           0.254          0.342  106.633
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No

# Not normally needed. You'd clear a default or registration only to
# undo a mistake, or -- as in this example -- to reset state for testing.
jdummy(community, NULL)
#> Dummy registrations cleared for community: Region.
juse(NULL)
#> Default data frame cleared.
```
