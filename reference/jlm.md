# SPSS-like linear regression output with standardized coefficients

Fits a linear model using
[`stats::lm()`](https://rdrr.io/r/stats/lm.html) and prints SPSS-style
output, including unstandardized coefficients, standard errors, t
values, p values, and standardized coefficients (beta). Standardized
coefficients are left blank for the intercept and for dummy-coded
categorical terms.

## Usage

``` r
jlm(
  formula,
  data,
  subset = NULL,
  variable.id = NULL,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  ci = NULL,
  std = "regular",
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

  A model formula, e.g. `y ~ x1 + x2`. Transformed terms such as
  `log(y)` or `I(x1^2)` are computed automatically and used throughout
  the output.

- data:

  A data frame containing variables referenced in `formula`.

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
  replaces each coefficient's variable name with its label in the
  Coefficients table (factor level decoration is preserved) – best for
  short labels; `"legend"` prints a label legend between the
  Coefficients table and the R-squared/fit block; `"legend.bottom"`
  prints it at the very end. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- numeric:

  Optional character vector of variable names that should be treated as
  continuous (numeric) even if they have value labels. For example,
  `numeric = "Age"` or `numeric = c("Age", "Education")`.

- categorical:

  Optional character vector of variable names that should be treated as
  categorical even if they lack value labels. For example,
  `categorical = "Program"` or `categorical = c("Program", "Region")`.
  The first sorted unique value becomes the reference category. Use
  [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) for
  control over the reference category.

- count:

  Optional character vector of variable names to treat as counts for
  this call (the per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)). On
  the dependent variable it speaks the count-regression caveat
  definitively rather than as a hedge, and applies even when the
  variable sits outside the structural 0-6 band. On an independent
  variable it behaves like `numeric` (a count predictor enters the model
  as numeric). A variable cannot be listed in both `count` and
  `categorical`.

- ci:

  Logical or NULL. If TRUE, appends a 95% confidence interval for each
  unstandardized coefficient (b) at the right of the coefficient table.
  If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  regression.ci setting (off at minimal and standard, on at full).
  Computed as the closed form b +/- t(.975, residual df) \* SE.

- std:

  Character. Controls the standardized-coefficient column. One of
  `"regular"` (default) – standardized betas with the prevalence-scaled
  betas of dummy and dichotomous predictors suppressed, since a fully
  standardized beta on a 0/1 indicator is not comparable to the
  continuous betas (an interaction row built on such a predictor is
  suppressed with it); `"all"` – the same standardized betas with
  nothing suppressed; `"gelman"` – Gelman (2008) scaling (shown for all
  predictors, and headed "Gelman beta"); `"product"` – each predictor
  standardized as it stands, the product of an interaction and a squared
  term included, as some other software does (shown for all predictors,
  and headed "Product beta"); or `"none"` – omit the column. The
  returned object always carries the full regular betas (`beta`), the
  full Gelman betas (`beta_gelman`) and the full product betas
  (`beta_product`) regardless of this display choice.

  The regular betas come from refitting the model on z-scored variables,
  so in a model with an interaction the product is formed from the
  standardized predictors (Aiken and West, 1991). Some software
  standardizes the product column itself instead, which is what
  `std = "product"` does; see the section Comparing with other software.

  The Gelman betas come from refitting the model with every predictor
  centered, a continuous predictor also divided by two standard
  deviations and a binary predictor (a 0/1 variable, or a category's
  dummy variable) left on its one-unit scale; the outcome keeps its own
  units. A continuous predictor's Gelman beta is the change in the
  outcome for a move from one standard deviation below its mean to one
  above; a binary predictor's is the difference between its two groups;
  the two are comparable, which is the point of the scaling. Every 0/1
  column is centered, including the dummy variables of a categorical
  predictor with three or more categories, which `arm::standardize()`
  leaves at 0/1 (its rescaling reaches only the variables named in the
  formula), so on such a model a main effect that interacts with that
  predictor is the sample-average effect here and the reference-category
  effect there.

  A computed term that is a power or a product of variables, such as
  `I(x^2)` or `I(x * z)`, is recomputed from the rescaled variables in
  both refits, as Gelman (2008, section 3.1) does: the square of the
  rescaled `x`, not the rescaled square. Any other computed term –
  `log(x)`, a ratio, a condition such as `I(x > 10)` – is an input of
  its own and is rescaled as a column.

  In a model with an interaction or a squared term, both refits center
  the predictors, so a main effect's standardized beta is its effect at
  the average of the predictor it interacts with (a squared term's
  variable, at its own average), while its b is the effect when that
  predictor is 0; the two can differ in sign. A note under the
  coefficient table says so, and points to the section Comparing with
  other software, whenever such a model shows a standardized column. A
  variable that equals the product of two other predictors in the model,
  or the square of one, is named in a note of its own, and under
  `std = "product"` a note says which convention the column follows.

- diagnostics:

  Logical, character vector, or NULL. If TRUE, prints VIF table and
  diagnostic plots. If a character vector, specifies which diagnostics
  to show: `vif`, `residuals`, `qq`, `scale`, `cooks`, `leverage`. If
  NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  session setting.

- ref.categories:

  Logical or NULL. Per-call override for showing the
  reference-categories block (the baseline level dropped from each set
  of dummy variables). `NULL` (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `ref.categories` setting. Applies to `jlm()` and
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
  only, since they are the functions that produce dummy-coded
  coefficient tables.

- full:

  Logical. If TRUE, turns on the coefficient confidence interval and
  diagnostics. Does not override explicit FALSE values.

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

Invisibly returns a list of class `jst_lm` containing:

- model:

  The fitted `lm` object.

- model_type:

  Character string `linear`.

- model_frame:

  The model frame used to fit the model.

- formula_used:

  The formula after dummy expansion.

- coefficients:

  Formatted coefficient table (data frame); includes 95% CI Lower /
  Upper columns when `ci` is on.

- coefficients_raw:

  Flat data frame of raw, full-precision coefficient statistics (one row
  per coefficient): `term` (machine key), `b`, `SE`, `t`, `df`, `p`,
  `beta`, `beta_gelman`, `beta_product`, and `ci_lower` / `ci_upper`
  bounds (present regardless of the `ci` display toggle). Carries
  `beta_standardization` and `outcome` attributes.

- fit_raw:

  List of raw, full-precision fit statistics (R-squared, adjusted
  R-squared, residual SE, F with its dfs and p-value, residual df, and
  N).

- r_squared:

  R-squared value.

- adj_r_squared:

  Adjusted R-squared value.

- residual_se:

  Residual standard error.

- f_statistic:

  Named numeric vector with F value, df1, df2, and p.

- sums_of_squares:

  Named numeric vector (regression, residual, total).

- n:

  Number of observations used in the model.

- dummy_coef_names:

  Names of dummy variable columns created by
  [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
  registrations.

- ref_cats:

  Reference category descriptions for all categorical variables in the
  model.

- vif:

  Named numeric vector of VIF values, or NULL for bivariate.

- sample_info:

  Pipeline and missing data counts.

## Details

Also prints key model summary information (R-squared, adjusted
R-squared, residual standard error, F-test, sums of squares, and N). If
any coefficients are dropped due to perfect collinearity, a warning
message is printed.

A red "Linear Regression" title is printed first, followed by variable
labels (if present), then the coefficient table and model fit
statistics.

**Handling of variables:**

- Variables registered with
  [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) are
  expanded into dummy variables using the registered reference category.
  A registered category with no case in the analysis sample (removed by
  a filter, or emptied by listwise deletion) is left out of that model;
  if it is the reference category, the first remaining category is the
  reference for that model instead. A note reports either, and the
  coefficient table's header names the reference actually used. The
  registration itself is not changed.

- Unregistered haven-labelled variables with value labels are
  automatically treated as categorical (converted to factors). The first
  category is used as the reference, and an informational message
  suggests using
  [`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) for
  control over the reference category.

- Haven-labelled variables without value labels are treated as
  continuous (converted to numeric).

- The `numeric` argument overrides auto-detection for variables that
  have value labels but should be treated as continuous (e.g. Age with
  labels like "18 years", "19 years").

- The `categorical` argument forces variables without value labels (or
  plain numeric variables) to be treated as categorical (e.g. a numeric
  Program variable coded 1–4 from a CSV file).

- The dependent variable is always modelled as numeric. Naming it in
  `numeric` or `count` does not change that; it only asserts the DV's
  role so the count / categorical-like note is silenced (`numeric`) or
  stated definitively (`count`).

Transformed terms in `formula` are computed automatically. A term that
applies a function to a variable – `log(x)`, `sqrt(x)`, `exp(x)`,
`I(x^2)`, `scale(x)`, an arithmetic expression, or a logical condition
such as `I(x > 10)` – is evaluated once on the analysis data and enters
the model as a single derived column named for the expression, so the
coefficient table, the group descriptives, and the standardized-beta
refit all report the term as written. This follows the base R formula
convention; the terms supported inline are those that evaluate to one
numeric or logical column. Terms that produce several columns
(`poly(x, 2)`, spline bases) or a categorical result (`cut(x, 3)`) are
not supported inline: create the derived variable as a column of the
data first, then name that column in the formula. A value or vector from
your workspace may be named inside a computed term, as in
[`lm()`](https://rdrr.io/r/stats/lm.html): `I(x > cutoff)` with
`cutoff <- 10`. A data frame may not: write `y ~ x` with
`data = MyData`, not `MyData$y ~ MyData$x`. A vector used value by value
with the data, as in `I(x * w)`, must hold one value for each case –
each row of `data` left after filtering – where
[`lm()`](https://rdrr.io/r/stats/lm.html) would recycle a shorter one; a
set used with `%in%` may have any length.

In a formula, `^` applied to a single variable is not arithmetic: it is
R's operator for interactions up to that order, so `x^2` enters the
model as `x` alone. Write `I(x^2)` for the square. `jlm()` fits the
model as written and then warns when a formula does this. A power that
is not a number, `x^k`, stops with an error, as in
[`lm()`](https://rdrr.io/r/stats/lm.html); write `I(x^k)`.

## Comparing with other software

Two conventions exist for the standardized coefficients of a model with
an interaction or a squared term, and they give different numbers for
the same model.

The first convention standardizes the inputs and forms the product, or
the square, from them. The default column and the Gelman column follow
it: `std = "regular"` refits the model on z-scored variables (Aiken and
West, 1991), and `std = "gelman"` refits it on centered, rescaled
predictors (Gelman, 2008). In R, `arm::standardize()` follows it for the
Gelman scaling, and the default refit of
`effectsize::standardize_parameters()` for the regular one; both agree
with jstats when every predictor is numeric. Both differ from jstats on
a categorical predictor of three or more categories. jstats rescales its
dummy variables (see `std`); those packages take the predictor as an R
factor (base R's form for a categorical variable, where jstats uses a
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md)
registration) and leave its dummy variables at 0/1. Some of their betas
then differ, among them the beta of a main effect that interacts with
that predictor.

The second convention standardizes the product column itself, as though
the product were an ordinary predictor, and a squared term's column the
same way. SPSS REGRESSION reports this beta, since there the product is
computed as a new variable and entered like any other, and
`effectsize::standardize_parameters(method = "basic")` gives it in R. In
jstats, `std = "product"` gives it. On this convention the betas of the
product and of the main effects differ from those of the first, and they
depend on where each variable's zero falls: adding a constant to one of
the variables fits the same model but changes them, while the first
convention's betas stay the same.

Only the standardized columns differ: b, its standard error, t, p and
R-squared are the same under both. The same split appears within jstats.
A product computed by hand and entered as its own variable (a column
`xz` made from `x * z`, then `y ~ x + z + xz`) fits the same model as
`y ~ x * z`, but jstats cannot see its parts, so its standardized
columns follow the second convention; a note under the table names the
variable when it equals the product of two other predictors in the
model, or the square of one.

jstats follows the first convention and recommends it: enter an
interaction in the formula, as `x * z`, and a squared term as `I(x^2)`.
If you prefer the second convention instead – to match SPSS REGRESSION,
say – use `std = "product"`.

## References

Aiken, L. S., and West, S. G. (1991). *Multiple Regression: Testing and
Interpreting Interactions*. Sage.

Gelman, A. (2008). Scaling regression inputs by dividing by two standard
deviations. *Statistics in Medicine*, 27(15), 2865-2873.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame (named argument)
jlm(WellbeingScore ~ Income + Age, data = community)
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Income
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE     t      β      p
#> -----------  ------  -----  -----  -----  -----
#> (Intercept)  24.815  3.749  6.620         <.001
#> Income        0.000  0.000  6.813  0.564  <.001
#> Age           0.181  0.082  2.208  0.183   .030
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.411    Adjusted R-squared: 0.398
#> Residual Standard Error: 9.013
#> 
#> F-statistic: 32.729 on 2 and 94 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 5317.416
#>   Residual:   7635.945
#>   Total:      12953.361
#> 

# With explicit data frame (positional argument)
jlm(WellbeingScore ~ Income + Age, community)
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Income
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE     t      β      p
#> -----------  ------  -----  -----  -----  -----
#> (Intercept)  24.815  3.749  6.620         <.001
#> Income        0.000  0.000  6.813  0.564  <.001
#> Age           0.181  0.082  2.208  0.183   .030
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.411    Adjusted R-squared: 0.398
#> Residual Standard Error: 9.013
#> 
#> F-statistic: 32.729 on 2 and 94 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 5317.416
#>   Residual:   7635.945
#>   Total:      12953.361
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jlm(WellbeingScore ~ Income + Age)
#> Linear Regression
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Income
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE     t      β      p
#> -----------  ------  -----  -----  -----  -----
#> (Intercept)  24.815  3.749  6.620         <.001
#> Income        0.000  0.000  6.813  0.564  <.001
#> Age           0.181  0.082  2.208  0.183   .030
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.411    Adjusted R-squared: 0.398
#> Residual Standard Error: 9.013
#> 
#> F-statistic: 32.729 on 2 and 94 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 5317.416
#>   Residual:   7635.945
#>   Total:      12953.361
#> 

# CATEGORICAL PREDICTORS
#
# Per-call: categorical = ... applies for one call only and does not
# persist. Useful for a quick one-off analysis.
jlm(WellbeingScore ~ Region + Age, categorical = "Region")
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                             b      SE      t      β      p
#> -----------------------  ------  -----  ------  -----  -----
#> (Intercept)              38.910  4.227   9.204         <.001
#> Region (ref = 1: North)
#>   2: South               -5.502  3.197  -1.721          .088
#>   3: East                -1.872  2.848  -0.657          .513
#>   4: West                -3.687  3.029  -1.217          .226
#> Age                       0.357  0.093   3.820  0.361  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 

# The recommended approach for repeated analyses: register the variable
# with jdummy() before running jlm(). This sets the categorical
# treatment persistently, so subsequent jlm() calls (and other
# analyses) use the same coding without re-specifying.
jdummy(community, Region)
#> Dummy Variable Registration
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_North
#>   Dummy variables: Region_South, Region_East, Region_West
#>   Cases: 103 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   jload("community.rds")
jlm(WellbeingScore ~ Region + Age)
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                             b      SE      t      β      p
#> -----------------------  ------  -----  ------  -----  -----
#> (Intercept)              38.910  4.227   9.204         <.001
#> Region (ref = 1: North)
#>   2: South               -5.502  3.197  -1.721          .088
#>   3: East                -1.872  2.848  -0.657          .513
#>   4: West                -3.687  3.029  -1.217          .226
#> Age                       0.357  0.093   3.820  0.361  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 

# To choose a non-default reference category:
jdummy(community, Region, ref = "West")
#> Dummy Variable Registration
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_West
#>   Dummy variables: Region_North, Region_South, Region_East
#>   Cases: 103 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   jload("community.rds")
jlm(WellbeingScore ~ Region + Age)
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                            b      SE      t      β      p
#> ----------------------  ------  -----  ------  -----  -----
#> (Intercept)             35.223  4.617   7.630         <.001
#> Region (ref = 4: West)
#>   1: North               3.687  3.029   1.217          .226
#>   2: South              -1.815  3.253  -0.558          .578
#>   3: East                1.815  2.941   0.617          .539
#> Age                      0.357  0.093   3.820  0.361  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 

# FORCING NUMERIC TREATMENT
#
# Use numeric = ... when a variable has value labels (haven_labelled)
# but you want it treated as a continuous score (e.g., a Likert
# scale you want the slope-per-unit interpretation for).
jlm(WellbeingScore ~ Age + Education, numeric = "Education")
#> Linear Regression
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise         6         97
#>     Analysis N           --         97
#> 
#> Missing data   From 103   %
#>     Education
#>       Missing      6     5.8
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE     t      β      p
#> -----------  ------  -----  -----  -----  -----
#> (Intercept)  25.688  3.789  6.780         <.001
#> Age           0.343  0.078  4.376  0.354  <.001
#> Education     4.087  0.653  6.262  0.506  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.386    Adjusted R-squared: 0.373
#> Residual Standard Error: 9.058
#> 
#> F-statistic: 29.602 on 2 and 94 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 4857.995
#>   Residual:   7713.097
#>   Total:      12571.093
#> 

# Multiple overrides at once
jlm(WellbeingScore ~ Education + Environment4 + Smoker,
    numeric = c("Education", "Environment4"), categorical = "Smoker")
#> Linear Regression
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --        103
#>     Auto-listwise        11         92
#>     Analysis N           --         92
#> 
#> Missing data   From 103   %
#>     Education
#>       Missing      6     5.8
#>     Smoker
#>       Missing      5     4.9
#> --------------------------------------
#> 
#> Coefficients
#>                  b      SE      t       β      p
#> ------------  ------  -----  ------  ------  -----
#> (Intercept)   37.934  3.455  10.979          <.001
#> Education      4.637  0.791   5.860   0.560  <.001
#> Environment4  -0.365  0.910  -0.401  -0.038   .690
#> Smoker_Yes     3.116  2.201   1.416           .160
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.296    Adjusted R-squared: 0.272
#> Residual Standard Error: 9.934
#> 
#> F-statistic: 12.352 on 3 and 88 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 3656.493
#>   Residual:   8683.365
#>   Total:      12339.859
#> 

# STANDARDIZED COEFFICIENTS
#
# The default (std = "regular") leaves the beta blank on the dummy rows.
# std = "all" shows it there too; std = "gelman" puts continuous and
# dummy predictors on one comparable scale; std = "none" drops the column.
jlm(WellbeingScore ~ Region + Age, std = "all")
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                            b      SE      t       β      p
#> ----------------------  ------  -----  ------  ------  -----
#> (Intercept)             35.223  4.617   7.630          <.001
#> Region (ref = 4: West)
#>   1: North               3.687  3.029   1.217   0.142   .226
#>   2: South              -1.815  3.253  -0.558  -0.063   .578
#>   3: East                1.815  2.941   0.617   0.073   .539
#> Age                      0.357  0.093   3.820   0.361  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 
jlm(WellbeingScore ~ Region + Age, std = "gelman")
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                            b      SE      t    Gelman β    p
#> ----------------------  ------  -----  ------  --------  -----
#> (Intercept)             35.223  4.617   7.630            <.001
#> Region (ref = 4: West)
#>   1: North               3.687  3.029   1.217    3.687    .226
#>   2: South              -1.815  3.253  -0.558   -1.815    .578
#>   3: East                1.815  2.941   0.617    1.815    .539
#> Age                      0.357  0.093   3.820    8.295   <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 
jlm(WellbeingScore ~ Region + Age, std = "none")
#> Linear Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                            b      SE      t      p
#> ----------------------  ------  -----  ------  -----
#> (Intercept)             35.223  4.617   7.630  <.001
#> Region (ref = 4: West)
#>   1: North               3.687  3.029   1.217   .226
#>   2: South              -1.815  3.253  -0.558   .578
#>   3: East                1.815  2.941   0.617   .539
#> Age                      0.357  0.093   3.820  <.001
#> 
#> Outcome: WellbeingScore
#> 
#> R-squared: 0.147    Adjusted R-squared: 0.112
#> Residual Standard Error: 10.819
#> 
#> F-statistic: 4.216 on 4 and 98 DF, p-value: .003
#> Sum of Squares:
#>   Regression: 1974.261
#>   Residual:   11471.564
#>   Total:      13445.825
#> 

# An interaction, entered in the formula so the standardized column is
# built from the inputs (see the section Comparing with other software)
jlm(Flourishing ~ SocialSupport * Stress, data = clinic)
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --         70
#>     Auto-listwise         4         66
#>     Analysis N           --         66
#> 
#> Missing data   From 70   %
#>     Stress
#>       Missing     4     5.7
#> --------------------------------------
#> 
#> Coefficients
#>                            b      SE       t       β      p
#> ----------------------  ------  ------  ------  ------  -----
#> (Intercept)             78.089  11.164   6.995          <.001
#> SocialSupport           -1.573   0.740  -2.126   0.285   .037
#> Stress                  -2.576   0.588  -4.385  -0.176  <.001
#> SocialSupport * Stress   0.159   0.041   3.873   0.400  <.001
#> 
#> In a model with an interaction, β comes from centered predictors: a β can have
#> the opposite sign from its b, and other software may report different β values.
#> See ?jlm.
#> 
#> Outcome: Flourishing
#> 
#> R-squared: 0.366    Adjusted R-squared: 0.335
#> Residual Standard Error: 11.635
#> 
#> F-statistic: 11.911 on 3 and 62 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 4837.188
#>   Residual:   8393.297
#>   Total:      13230.485
#> 

# A squared term, written with I(); its standardized value is built from
# the standardized Stress
jlm(Flourishing ~ Stress + I(Stress^2), data = clinic)
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --         70
#>     Auto-listwise         4         66
#>     Analysis N           --         66
#> 
#> Missing data   From 70   %
#>     Stress
#>       Missing     4     5.7
#> --------------------------------------
#> 
#> Coefficients
#>                 b      SE      t       β      p
#> -----------  ------  -----  ------  ------  -----
#> (Intercept)  50.111  5.210   9.618          <.001
#> Stress        0.711  0.607   1.171  -0.262   .246
#> I(Stress^2)  -0.040  0.017  -2.296  -0.154   .025
#> 
#> In a model with a squared term, β comes from centered predictors: a β can have
#> the opposite sign from its b, and other software may report different β values.
#> See ?jlm.
#> 
#> Outcome: Flourishing
#> 
#> R-squared: 0.163    Adjusted R-squared: 0.136
#> Residual Standard Error: 13.260
#> 
#> F-statistic: 6.125 on 2 and 63 DF, p-value: .004
#> Sum of Squares:
#>   Regression: 2153.689
#>   Residual:   11076.796
#>   Total:      13230.485
#> 

# The second convention: each predictor standardized as it stands, the
# beta SPSS REGRESSION reports for a product computed as a new variable
jlm(Flourishing ~ SocialSupport * Stress, data = clinic, std = "product")
#> Linear Regression
#> 
#> Case Processing    Excluded  Remaining
#>     Original             --         70
#>     Auto-listwise         4         66
#>     Analysis N           --         66
#> 
#> Missing data   From 70   %
#>     Stress
#>       Missing     4     5.7
#> --------------------------------------
#> 
#> Coefficients
#>                            b      SE       t    Product β    p
#> ----------------------  ------  ------  ------  ---------  -----
#> (Intercept)             78.089  11.164   6.995             <.001
#> SocialSupport           -1.573   0.740  -2.126    -0.536    .037
#> Stress                  -2.576   0.588  -4.385    -1.337   <.001
#> SocialSupport * Stress   0.159   0.041   3.873     1.320   <.001
#> 
#> Product β treats each interaction as an ordinary predictor, as some other
#> software does.
#> See ?jlm.
#> 
#> Outcome: Flourishing
#> 
#> R-squared: 0.366    Adjusted R-squared: 0.335
#> Residual Standard Error: 11.635
#> 
#> F-statistic: 11.911 on 3 and 62 DF, p-value: <.001
#> Sum of Squares:
#>   Regression: 4837.188
#>   Residual:   8393.297
#>   Total:      13230.485
#> 

# jdummy(community, NULL) clears its registration -- not normally needed.
# You'd clear a default or registration only to undo a mistake, or -- as
# in this example -- to reset state for testing.
jdummy(community, NULL)
#> Dummy registrations cleared for community: Region.
juse(NULL)
#> Default data frame cleared.
```
