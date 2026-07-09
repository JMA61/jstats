# Bivariate correlation matrix with p values and pairwise N

Computes pairwise correlations and prints a formatted lower-triangle
correlation matrix showing r, p values, and pairwise N for each pair.
Supports Pearson (default), Spearman, and Kendall methods. Handles
haven-labelled and factor variables with numeric levels. Warns when
variables may be categorical rather than continuous.

## Usage

``` r
jcorr(
  data,
  ...,
  method = "pearson",
  subset = NULL,
  variable.id = NULL,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  value.id = NULL,
  layout = NULL,
  case.processing.detail = NULL,
  digits = NULL
)
```

## Arguments

- data:

  A data frame.

- ...:

  Unquoted variable names within `data`.

- method:

  Character. Correlation method: "pearson" (default), "spearman", or
  "kendall".

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows variable labels as the matrix row/column headers (honored even
  if the matrix grows wide – best for short labels; rerun with a legend
  mode otherwise); `"legend"`/`"legend.bottom"` keep names and print a
  label legend after the table. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- numeric:

  Optional character vector of variable names to treat as continuous for
  this call (the per-call counterpart of
  [`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md)).
  Its only effect in `jcorr()` is to suppress the structural "seems
  categorical" caution for those variables; correlations are computed
  the same way regardless (labelled variables are coerced to numeric
  either way).

- categorical:

  Not supported by `jcorr()` yet. Correlation requires numeric
  variables; supplying `categorical` raises an error pointing to
  [`jcrosstab()`](https://jma61.github.io/jstats/reference/jcrosstab.md)
  for association between categorical variables. (How `jcorr()` should
  handle an asserted-categorical variable is a parked design decision.)

- count:

  Optional character vector of variable names to treat as counts for
  this call (the per-call counterpart of
  [`jcount()`](https://jma61.github.io/jstats/reference/jcount.md)). A
  count is numeric-like here, so it behaves like `numeric`: it
  suppresses the "seems categorical" caution for those variables.

- value.id:

  Not supported by `jcorr()`. The function does not display value
  labels, so passing this argument is an error. It exists only to return
  a clear message rather than misreporting the token as a missing
  variable. Leave at NULL (default).

- layout:

  Character or NULL. How each correlation cell is laid out when three or
  more variables are given: `"wide"` (default) puts r and its p-value on
  one line with N on a second line beneath; `"stacked"` places r, p, and
  N on three separate lines, giving a narrower table that fits more
  variables before wrapping. Ignored for a single pair (two variables),
  which always prints a one-line summary. NULL (default) defers to the
  `corr.layout` setting in
  [`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
  (itself defaulting to "wide").

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

Invisibly returns a list of class `jst_corr` containing: `r`
(correlation matrix), `p` (p-value matrix), `n` (pairwise N matrix),
`method`, `model_frame` (the analysis data frame used for plotting), and
`sample_info` (pipeline and missing data counts).

## Details

A red title identifying the correlation method is printed first,
followed by variable labels (if present), then the matrix.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jcorr(community, Income, Age, WellbeingScore)
#> Pearson Bivariate Correlations
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        103
#>     Remaining N         —        103
#> 
#> Missing-data breakdown  From 103    %
#>     Income
#>       Missing              6      5.8
#> 
#> ─────────────────────────────────────
#> 
#> Bivariate Correlations (Pearson)
#>                 Income          Age             WellbeingScore
#> --------------  --------------  --------------  --------------
#> Income           1                                            
#>                                                               
#> Age              .289 (p=.004)   1                            
#>                 N=97                                          
#>                                                               
#> WellbeingScore   .616 (p<.001)   .343 (p<.001)   1            
#>                 N=97            N=103                         
#> 
jcorr(community, Income, Age, WellbeingScore, method = "spearman")
#> Spearman Bivariate Correlations
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        103
#>     Remaining N         —        103
#> 
#> Missing-data breakdown  From 103    %
#>     Income
#>       Missing              6      5.8
#> 
#> ─────────────────────────────────────
#> 
#> Bivariate Correlations (Spearman)
#>                 Income          Age             WellbeingScore
#> --------------  --------------  --------------  --------------
#> Income           1                                            
#>                                                               
#> Age              .305 (p=.002)   1                            
#>                 N=97                                          
#>                                                               
#> WellbeingScore   .606 (p<.001)   .378 (p<.001)   1            
#>                 N=97            N=103                         
#> 
#> Note: Spearman p-values are approximate due to tied values in the data.
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jcorr(Income, Age, WellbeingScore)
#> Pearson Bivariate Correlations
#> Using default data frame: community
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        103
#>     Remaining N         —        103
#> 
#> Missing-data breakdown  From 103    %
#>     Income
#>       Missing              6      5.8
#> 
#> ─────────────────────────────────────
#> 
#> Bivariate Correlations (Pearson)
#>                 Income          Age             WellbeingScore
#> --------------  --------------  --------------  --------------
#> Income           1                                            
#>                                                               
#> Age              .289 (p=.004)   1                            
#>                 N=97                                          
#>                                                               
#> WellbeingScore   .616 (p<.001)   .343 (p<.001)   1            
#>                 N=97            N=103                         
#> 
```
