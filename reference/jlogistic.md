# Logistic regression with SPSS-style output

Fits a binary logistic regression using
[`stats::glm()`](https://rdrr.io/r/stats/glm.html) with
`family = binomial` and prints formatted output including an omnibus
model test, model summary statistics, and a coefficients table with
Gelman-standardized coefficients and odds ratios (Exp(b)).

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
  value.id = NULL,
  model.layout = NULL,
  std = "gelman"
)
```

## Arguments

- formula:

  A model formula, e.g. `DV ~ IV1 + IV2`. The DV must be a binary
  variable coded 0/1, and a variable of the data: a computed term on the
  left, such as `I(Score > 50)`, is refused, so create the 0/1 variable
  first. Transformed predictor terms such as `log(IV1)` are computed
  automatically and used throughout the output.

- data:

  A data frame containing variables referenced in `formula`.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Written in R syntax and checked the way
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
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
  short labels; `"legend"` prints a label legend just below the
  Coefficients table (at the coefficients/fit seam); `"legend.bottom"`
  prints it at the very end. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- numeric:

  Optional. Variables to treat as continuous even if they have value
  labels, named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html).

- categorical:

  Optional. Variables to treat as categorical even if they lack value
  labels, named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html): `categorical = Region`.

- count:

  Optional. Independent variables to treat as counts for this call (the
  per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)),
  named bare or in quotes, several with
  [`c()`](https://rdrr.io/r/base/c.html). A count predictor is
  numeric-like, so it enters the model exactly as `numeric` would; the
  argument is provided for symmetry with the other analysis functions.
  The binary dependent variable is fixed, so naming it here has no
  effect. A variable cannot be listed in both `count` and `categorical`.

- ci:

  Logical or NULL. If TRUE, adds 95% confidence intervals for Exp(b). If
  NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).

- classification:

  Logical. If TRUE, prints a classification table showing predicted vs
  observed outcomes. Default is FALSE.

- diagnostics:

  Logical, character vector, or NULL. If TRUE, prints the VIF table (for
  a model with two or more predictors) and draws three diagnostic plots:
  binned residuals, Cook's distance, and residuals against leverage. A
  character vector names the ones to show: `vif`, `binned`, `cooks`,
  `leverage`, more than one combined with
  [`c()`](https://rdrr.io/r/base/c.html), as in
  `diagnostics = c("vif", "cooks")`; a name that is not one of these is
  an error. The VIF values are the predictors' ordinary variance
  inflation factors, computed from their correlations as for a linear
  model. A VIF above 10 gets a line of interpretation under the table,
  except at `joutput("minimal")`. In a model with a predictor of three
  or more categories the table gives each predictor one row with its
  generalized VIF, Df and GVIF^(1/(2\*Df)), the dummy variables sharing
  a row, as in
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md); computed
  from the correlations, these differ a little from `car::vif()` on a
  `glm`, which uses the coefficients' covariance. If NULL (default),
  defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `diagnostics` setting, which is off at every output level until it is
  set. The plots, and the probability, ROC, calibration and odds-ratio
  plots, are available afterwards from
  [`jplot()`](https://jma61.github.io/jstats/reference/jplot.md) on the
  returned object.

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

  Logical. If TRUE, turns on ci and classification. Does not override an
  explicit FALSE, and does not turn on diagnostics, which `diagnostics`
  alone governs.

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

- model.layout:

  Character or NULL. The order of the coefficient table and the fit
  statistics: `"coefficients"` (the default) prints the Coefficients
  table first and the fit block after it; `"fit"` prints the fit block
  first, for readers who look at the model as a whole before its
  coefficients. The Case Processing block, the diagnostics and the other
  tables stay where they are. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `model.layout` setting.

- std:

  Character. The standardized-coefficient column, between p and Exp(b).
  One of `"gelman"` (default) – Gelman (2008) scaling, headed "Gelman
  beta"; `"product"` – each column of the model scaled as it stands, the
  product of an interaction and a squared term included (headed "Product
  beta"); or `"none"` – omit the column. See the section Standardized
  coefficients.
  [`jlm()`](https://jma61.github.io/jstats/reference/jlm.md)'s regular
  standardization (`"regular"`, `"all"`) divides by the outcome's
  standard deviation, which a binary outcome does not have, and is not
  available here. The returned object carries both columns' full values
  (`beta_gelman`, `beta_product`) whichever is shown.

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
  `Wald`, `df`, `p`, `exp_b`, `exp_ci_lower` / `exp_ci_upper` odds-ratio
  CI bounds (present regardless of the `ci` display toggle),
  `beta_gelman` and `beta_product` (the full standardized coefficients,
  whichever `std` shows). Carries `beta_standardization` and `outcome`
  attributes.

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

- dummy_groups:

  Named list, one element per dummy-coded variable: `labels`, its
  categories as the coefficient table labels them, and `dummy`, the
  dummy column of each (`NA` for the reference). Used by
  [`jplot()`](https://jma61.github.io/jstats/reference/jplot.md).

- vif:

  Named numeric vector of VIF values, or NULL.

- gvif:

  The generalized VIFs, when the model has a set of dummy variables (a
  predictor of three or more categories): a data frame of `term`,
  `GVIF`, `Df` and `GVIF_adj` (`GVIF^(1/(2*Df))`), one row per
  predictor, as the VIF table prints them; NULL otherwise.

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

A predictor dropped because it is an exact linear combination of the
others is named in a warning, as in
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md). A model with
no predictors, `y ~ 1`, is fitted too: its one coefficient is the log
odds of the modeled category, the pseudo R-squared values are 0, and the
Omnibus Test, which compares the model with that one, reads "None: the
model has no predictors to test." (its p is `NA` in the returned
object).

Transformed predictor terms in `formula` are computed automatically. A
term that applies a function to a variable – `log(x)`, `sqrt(x)`,
`exp(x)`, `I(x^2)`, `scale(x)`, an arithmetic expression, or a logical
condition such as `I(x > 10)` – is evaluated once on the analysis data
and enters the model as a single derived column named for the
expression, so the coefficient table and the diagnostics report the term
as written. This follows the base R formula convention; the terms
supported inline are those that evaluate to one numeric or logical
column. Terms that produce several columns (`poly(x, 2)`, spline bases)
or a categorical result (`cut(x, 3)`) are not supported inline: create
the derived variable as a column of the data first, then name that
column in the formula. (The dependent variable must be a plain 0/1
dichotomy, so a transform applies to predictors, not the response.) A
categorical variable may be compared but not transformed. `I(x == 2)`,
`I(x %in% c(1, 3))` and, for a text variable, `I(x == "web")` each enter
the model as a TRUE/FALSE predictor, as in
[`lm()`](https://rdrr.io/r/stats/lm.html); an order comparison such as
`I(x >= 3)` does too when `x` holds numbers. Arithmetic on a categorical
`x` – `log(x)`, `I(x^2)` – is refused, because it would be computed from
the category codes; register `x` with
[`jnumeric`](https://jma61.github.io/jstats/reference/jnumeric.md) if
its codes are meant as numbers. A value or vector from your workspace
may be named inside a computed term, as in
[`lm()`](https://rdrr.io/r/stats/lm.html): `I(x > cutoff)` with
`cutoff <- 10`. A data frame may not: write `y ~ x` with
`data = MyData`, not `MyData$y ~ MyData$x`. A variable may not: jstats
analyzes the variables of a data frame, so a vector holding one value
for each case – `w` in `I(x * w)`, or an object reached with `$` such as
`lst$w` – is added to the data frame first (`MyData$w <- w`), where
[`lm()`](https://rdrr.io/r/stats/lm.html) would read it from the
workspace; the stop gives that line. A vector of any other length used
value by value is refused, where
[`lm()`](https://rdrr.io/r/stats/lm.html) would repeat the shorter one;
a set used with `%in%` may have any length.

In a formula, `^` applied to a single variable is not arithmetic: it is
R's operator for interactions up to that order, so `x^2` enters the
model as `x` alone. Write `I(x^2)` for the square. `jlogistic()` fits
the model as written and then warns when a formula does this. A power
that is not a number, `x^k`, stops with an error, as in
[`lm()`](https://rdrr.io/r/stats/lm.html); write `I(x^k)`.

## Interactions

An interaction is entered in the formula with `*`, as in R: `y ~ x * z`
fits `x`, `z` and their product, and the product's row in the
coefficient table is labeled `x * z`. With a categorical predictor
registered with
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md), the
interaction rows are grouped under a header naming the reference
category, with one row per dummy variable, as the predictor's own rows
are. Each row's b is the change in the log-odds slope of one variable
per unit of the other (or, for a dummy row, the difference in slope
between that category and the reference), and its Exp(b) the factor by
which the other variable's odds ratio is multiplied per unit; the
main-effect rows give the slopes where the other variable is zero.
[`jplot`](https://jma61.github.io/jstats/reference/jplot.md) on the
result draws the probability plots.

## Standardized coefficients

A logistic regression's coefficients are in each predictor's own units,
so they cannot be compared across predictors measured differently. The
Gelman beta column puts them on one footing (Gelman, 2008): the model is
refit with every predictor centered, a continuous predictor also divided
by two standard deviations and a binary predictor (a 0/1 variable, or a
category's dummy variable) left on its one-unit scale. A continuous
predictor's Gelman beta is then the change in the log-odds for a move
from one standard deviation below its mean to one above, and a binary
predictor's the difference between its two groups, so the two are
comparable; [`exp()`](https://rdrr.io/r/base/Log.html) of a Gelman beta
is the odds ratio for that move. The outcome is not standardized – it
has no standard deviation to standardize by, which is why fully
standardized logistic coefficients are contested and this column uses
Gelman's scaling. It is the column `jlm(std = "gelman")` gives a linear
model, computed the same way.

A computed term that is a power or a product of variables, such as
`I(x^2)` or `I(x * z)`, is recomputed from the rescaled variables
(Gelman, 2008, section 3.1), as an interaction written `x * z` is. In a
model with an interaction or a squared term the predictors are centered,
so a main effect's Gelman beta is its effect at the average of the
variable it interacts with, while its b is the effect where that
variable is 0; the two can differ in sign, and a note under the table
says so. A variable that equals the product of two other predictors, or
the square of one, is named in a note of its own, since the column
treats it as an ordinary predictor.

`std = "product"` instead scales each column of the model as it stands –
b times two standard deviations of the column, a binary column's b
unchanged – the product of an interaction and a squared term included,
the convention of software that computes a product as a new variable. On
a model without such terms the two columns agree.

## References

Gelman, A. (2008). Scaling regression inputs by dividing by two standard
deviations. *Statistics in Medicine*, 27(15), 2865-2873.

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
#>                 b      SE    Wald   df    p    Gelman β  Exp(b)
#> -----------  ------  -----  ------  --  -----  --------  ------
#> (Intercept)  -3.824  1.049  13.287   1  <.001             0.022
#> Income        0.000  0.000   6.683   1   .010    1.266    1.000
#> Age           0.046  0.021   4.870   1   .027    1.069    1.047
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   16.705     2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      117.260            0.158          0.211      123.260
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# The data frame may also be given positionally
jlogistic(Volunteer ~ Income + Age, community)
#> Logistic Regression
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
#>                 b      SE    Wald   df    p    Gelman β  Exp(b)
#> -----------  ------  -----  ------  --  -----  --------  ------
#> (Intercept)  -3.824  1.049  13.287   1  <.001             0.022
#> Income        0.000  0.000   6.683   1   .010    1.266    1.000
#> Age           0.046  0.021   4.870   1   .027    1.069    1.047
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   16.705     2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      117.260            0.158          0.211      123.260
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# An interaction, entered in the formula with *
jlogistic(Volunteer ~ Income * Age, data = community)
#> Logistic Regression
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
#>                  b      SE    Wald  df    p   Gelman β  Exp(b)
#> ------------  ------  -----  -----  --  ----  --------  ------
#> (Intercept)   -7.631  3.212  5.645   1  .018             0.000
#> Income         0.000  0.000  3.516   1  .061    1.247    1.000
#> Age            0.142  0.078  3.308   1  .069    1.158    1.153
#> Income * Age   0.000  0.000  1.750   1  .186   -1.517    1.000
#> 
#> In a model with an interaction, Gelman β comes from centered predictors: a
#> Gelman β can have the opposite sign from its b, and other software may report
#> different Gelman β values.
#> See ?jlogistic.
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   18.580     3  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      115.385            0.174          0.233      123.385
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# A 1/2-coded dichotomy (Yes = 1, No = 2) must be recoded to 0/1 first
df <- community
df$OwnsHome01 <- jrecode(df, OwnsHome,
                         map = "1=1; 2=0", labels = "0=No; 1=Yes")
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.
jlogistic(OwnsHome01 ~ Income + Age, data = df)
#> Logistic Regression
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
#>                 b      SE    Wald   df    p    Gelman β  Exp(b)
#> -----------  ------  -----  ------  --  -----  --------  ------
#> (Intercept)  -4.788  1.168  16.800   1  <.001             0.008
#> Income        0.000  0.000  12.214   1  <.001    1.902    1.000
#> Age           0.046  0.022   4.635   1   .031    1.086    1.047
#> 
#> Outcome: OwnsHome01
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   25.108     2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      108.857            0.228          0.305      114.857
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jlogistic(Volunteer ~ Income + Age)
#> Logistic Regression
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
#>                 b      SE    Wald   df    p    Gelman β  Exp(b)
#> -----------  ------  -----  ------  --  -----  --------  ------
#> (Intercept)  -3.824  1.049  13.287   1  <.001             0.022
#> Income        0.000  0.000   6.683   1   .010    1.266    1.000
#> Age           0.046  0.021   4.870   1   .027    1.069    1.047
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   16.705     2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      117.260            0.158          0.211      123.260
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# CATEGORICAL PREDICTORS
#
# Per-call: categorical = ... applies for one call only and does not
# persist.
jlogistic(Volunteer ~ Region + Age, categorical = "Region")
#> Logistic Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                             b      SE    Wald  df    p   Gelman β  Exp(b)
#> -----------------------  ------  -----  -----  --  ----  --------  ------
#> (Intercept)              -2.240  0.864  6.716   1  .010             0.106
#> Region (ref = 1: North)
#>   2: South               -0.712  0.635  1.258   1  .262   -0.712    0.490
#>   3: East                -0.117  0.550  0.045   1  .831   -0.117    0.889
#>   4: West                 0.271  0.585  0.215   1  .643    0.271    1.312
#> Age                       0.055  0.020  7.825   1  .005    1.283    1.057
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  ----
#>   11.745     4  .019
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      130.801            0.108          0.144      140.801
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# The recommended approach for repeated analyses: register the variable
# with jdummy() before running jlogistic(). This sets categorical
# treatment persistently across subsequent analyses.
jdummy(community, Region)
#> Dummy Variable Registration
#>   Variable: Region
#>   Reference category: Region_North (default; change with ref =)
#>   Dummy variables: Region_South, Region_East, Region_West
#>   Cases: 103 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   jload("community.rds")
#> 
jlogistic(Volunteer ~ Region + Age)
#> Logistic Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                             b      SE    Wald  df    p   Gelman β  Exp(b)
#> -----------------------  ------  -----  -----  --  ----  --------  ------
#> (Intercept)              -2.240  0.864  6.716   1  .010             0.106
#> Region (ref = 1: North)
#>   2: South               -0.712  0.635  1.258   1  .262   -0.712    0.490
#>   3: East                -0.117  0.550  0.045   1  .831   -0.117    0.889
#>   4: West                 0.271  0.585  0.215   1  .643    0.271    1.312
#> Age                       0.055  0.020  7.825   1  .005    1.283    1.057
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  ----
#>   11.745     4  .019
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      130.801            0.108          0.144      140.801
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# To choose a non-default reference category:
jdummy(community, Region, ref = "West")
#> Dummy Variable Registration
#>   Variable: Region
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
#> 
jlogistic(Volunteer ~ Region + Age)
#> Logistic Regression
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Coefficients
#>                            b      SE    Wald  df    p   Gelman β  Exp(b)
#> ----------------------  ------  -----  -----  --  ----  --------  ------
#> (Intercept)             -1.969  0.940  4.384   1  .036             0.140
#> Region (ref = 4: West)
#>   1: North              -0.271  0.585  0.215   1  .643   -0.271    0.762
#>   2: South              -0.984  0.650  2.290   1  .130   -0.984    0.374
#>   3: East               -0.389  0.576  0.455   1  .500   -0.389    0.678
#> Age                      0.055  0.020  7.825   1  .005    1.283    1.057
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  ----
#>   11.745     4  .019
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      130.801            0.108          0.144      140.801
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# FORCING NUMERIC TREATMENT
#
# Use numeric = ... when a labelled variable should enter as a score.
jlogistic(Volunteer ~ Age + Education, numeric = "Education")
#> Logistic Regression
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
#>                 b      SE    Wald   df    p    Gelman β  Exp(b)
#> -----------  ------  -----  ------  --  -----  --------  ------
#> (Intercept)  -4.074  1.088  14.012   1  <.001             0.017
#> Age           0.058  0.021   7.597   1   .006    1.366    1.060
#> Education     0.591  0.172  11.843   1  <.001    1.674    1.805
#> 
#> Outcome: Volunteer
#> 
#> Omnibus Test of Model Coefficients
#> Chi-Square  df    p
#> ----------  --  -----
#>   21.547     2  <.001
#> 
#> Model Summary
#> -2 Log Likelihood  Cox & Snell R²  Nagelkerke R²    AIC
#> -----------------  --------------  -------------  -------
#>      112.913            0.199          0.266      118.913
#> 
#> Dependent Variable Encoding
#>   Modeled (1):   Yes
#>   Reference (0): No
#> 

# jdummy(community, NULL) clears its registration -- not normally needed.
# You'd clear a default or registration only to undo a mistake, or -- as
# in this example -- to reset state for testing.
jdummy(community, NULL)
#> Dummy registrations cleared for community: Region.
juse(NULL)
#> Default data frame cleared.
```
