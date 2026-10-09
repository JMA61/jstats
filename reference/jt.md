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
  diagnostics = NULL,
  ci = NULL,
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  case.processing.detail = NULL,
  full = FALSE,
  digits = NULL,
  ...
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
  assumed). If TRUE, runs Welch's t-test, which needs at least 2 cases
  in each group; Student's test can include a group of one case. Ignored
  when paired = TRUE.

- effect.size:

  Logical or NULL. If TRUE, prints Cohen's d. If NULL (default), defers
  to [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  session setting.

- diagnostics:

  Logical, `"levene"`, or NULL. If TRUE (or `"levene"`), prints Levene's
  test for homogeneity of variance, with a note under it when the test
  is significant (see "Unequal variances"). Not applicable when paired =
  TRUE. If NULL (default), defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `diagnostics` setting, which is off at every output level until it is
  set.

- ci:

  Logical or NULL. If TRUE, adds 95% confidence interval for the mean
  difference. If NULL (default), defers to
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
  level default. The Case Processing table itself prints only when a
  filter or listwise deletion excluded cases; otherwise a one-line N
  statement takes its place. See
  [`?joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  (`case.processing`).

- full:

  Logical. If TRUE, turns on effect.size and ci together. Does not
  override explicit FALSE values, and does not turn on diagnostics,
  which `diagnostics` alone governs.

- digits:

  Integer or NULL. Number of decimal places for continuous statistics in
  the output tables (range 0-7; `digits = 0` prints whole numbers with
  no trailing decimal point). Does not affect p-values, percentages, or
  integer quantities (counts, N, degrees of freedom), which keep their
  own fixed conventions. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `digits` setting (default 3).

- ...:

  Reserved for argument-name checking. Passing `levene`, the name of the
  diagnostics setting before version 0.9.219, produces an error that
  names `diagnostics`.

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
[`jlm`](https://jma61.github.io/jstats/reference/jlm.md). A value or
vector from your workspace may be named inside a computed term, as in
[`lm()`](https://rdrr.io/r/stats/lm.html): `I(x > cutoff)` with
`cutoff <- 10`. A data frame may not: write `y ~ x` with
`data = MyData`, not `MyData$y ~ MyData$x`. A vector used value by value
with the data, as in `I(x * w)`, must hold one value for each case –
each row of `data` left after filtering – where
[`lm()`](https://rdrr.io/r/stats/lm.html) would recycle a shorter one; a
set used with `%in%` may have any length.

## Unequal variances

Student's t-test assumes the two groups have the same variance, and
Levene's test (`diagnostics = TRUE`) asks whether they do. When it is
significant, a note under its table states the two things that decide
how much that matters – the ratio of the larger group's size to the
smaller, and of the larger standard deviation to the smaller – and then
takes one of three forms. Textbooks give different guidelines and no
single cutoff is agreed, so the note does not treat one as exact:

- Stevens (*Intermediate Statistics: A Modern Approach*; *Applied
  Multivariate Statistics for the Social Sciences*) holds that unequal
  variances distort the test appreciably only when the larger group is
  more than 1.5 times the smaller.

- Moore, McCabe and Craig (*Introduction to the Practice of Statistics*)
  treat results as approximately correct while the largest standard
  deviation is less than twice the smallest, a rule they state for the
  analysis of variance; Howell (*Statistical Methods for Psychology*)
  gives the same limit as a variance ratio of four and adds that unequal
  variances and unequal group sizes do not mix.

The note reads "usually still acceptable" when the larger group is no
more than 1.25 times the smaller and the larger standard deviation no
more than twice the smaller; it says the p-value may not be reliable
when the group sizes differ by more than 1.5 times and the standard
deviations by more than twice; and between the two it says that
guidelines differ. The 1.25 is not a textbook figure. It comes from
simulations run for jstats (a true null hypothesis, normal scores, a
nominal 5 percent level, the smaller group the more variable): in the
cases tried, Student's test rejected up to about 7 percent of the time
inside the first range, up to about 10 percent in the middle one, and
about 14 to 15 percent in the last. Two groups of the same size are the
most forgiving case: the rate stayed near 5 percent with one standard
deviation up to three times the other. The direction matters: when the
LARGER group is the more variable, the test rejects too rarely instead.
Welch's t-test (`welch = TRUE`) does not assume equal variances. The
note is not printed at `joutput("minimal")`, which prints the table
alone.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jt(WellbeingScore ~ Volunteer, data = community)
#> Independent Samples T-Test
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>    t     df    p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001       -7.211         -11.496       -2.925
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, data = community, welch = TRUE)
#> Welch's Independent Samples T-Test
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Welch's T-Test Results (equal variances not assumed)
#>    t      df     p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  -----  ----  ---------------  ------------  ------------
#> -3.362  100.7  .001       -7.211         -11.465       -2.956
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, data = community, full = TRUE)
#> Independent Samples T-Test
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>    t     df    p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001       -7.211         -11.496       -2.925
#> 
#> Cohen's d: -0.658
#> 

# Checking the equal-variances assumption: Levene's test
jt(WellbeingScore ~ Volunteer, data = community, diagnostics = TRUE)
#> Independent Samples T-Test
#> 
#> Analysis N: 103
#> 
#> Levene's Test for Homogeneity of Variance
#>   F    df1  df2    p
#> -----  ---  ---  ----
#> 0.719   1   101  .399
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>    t     df    p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001       -7.211         -11.496       -2.925
#> 
#> Cohen's d: -0.658
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jt(WellbeingScore ~ Volunteer)
#> Independent Samples T-Test
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>    t     df    p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001       -7.211         -11.496       -2.925
#> 
#> Cohen's d: -0.658
#> 
jt(WellbeingScore ~ Volunteer, full = TRUE)
#> Independent Samples T-Test
#> Using default data frame: community
#> 
#> Analysis N: 103
#> 
#> Group Descriptives: WellbeingScore by Volunteer
#> Group    N   Mean     SD
#> ------  --  ------  ------
#> 0: No   54  47.463  11.699
#> 1: Yes  49  54.673  10.059
#> 
#> Independent Samples T-Test Results (equal variances assumed)
#>    t     df    p   Mean Difference  95% CI Lower  95% CI Upper
#> ------  ---  ----  ---------------  ------------  ------------
#> -3.338  101  .001       -7.211         -11.496       -2.925
#> 
#> Cohen's d: -0.658
#> 
```
