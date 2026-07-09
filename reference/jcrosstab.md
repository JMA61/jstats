# Cross-tabulation with optional chi-square test of independence

Produces a cross-tabulation of two categorical variables, showing
observed frequencies and row percentages by default. Column percentages,
expected frequencies, adjusted standardized residuals, and a chi-square
test of independence are available via arguments. Handles
haven-labelled, numeric, factor, and character variables. For
haven-labelled variables, numeric codes are displayed alongside labels.

## Usage

``` r
jcrosstab(
  formula,
  data,
  chisq = FALSE,
  expected = FALSE,
  row.pct = TRUE,
  col.pct = FALSE,
  residuals = "none",
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  case.processing.detail = NULL,
  digits = NULL
)
```

## Arguments

- formula:

  A formula of the form `Row ~ Column`, naming plain variables.
  Transformed terms such as `log(x)` are not supported here – create the
  variable first (e.g. with [`cut()`](https://rdrr.io/r/base/cut.html)
  for binning), then cross-tabulate it.

- data:

  A data frame containing variables referenced in `formula`.

- chisq:

  Logical. If TRUE, prints the chi-square test of independence below the
  cross-tabulation. For a 2x2 table, two rows are shown – the Pearson
  chi-square and the Yates continuity-corrected chi-square – matching
  the rows commercial statistical software reports; the Pearson row is
  the headline result and is what the returned object carries. Larger
  tables show the single Pearson result (the correction applies only to
  2x2 tables). Default is FALSE.

- expected:

  Logical. If TRUE, prints expected frequencies alongside observed.
  Default is FALSE.

- row.pct:

  Logical. If TRUE (default), shows row percentages.

- col.pct:

  Logical. If TRUE, shows column percentages. Default is FALSE.

- residuals:

  Character. Cell residuals to display: `"none"` (default) or
  `"adjusted"`. `"adjusted"` adds an `(Adj.Res.)` line to each cell
  showing the adjusted standardized (Haberman) residual: (observed -
  expected) divided by its standard error. Under independence these are
  approximately standard normal, so a value beyond +/-1.96 flags a cell
  whose count departs from expected at the .05 level. This localizes a
  significant chi-square to individual cells, and matches the "Adjusted
  standardized" residual in SPSS CROSSTABS. At `joutput("full")` the
  residual cells are flagged (`*` past +/-1.96, `**` past the Bonferroni
  cutoff) and an interpretation note is printed below the table naming
  both thresholds. Not a logical.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows the row/column variable labels (table header and caption; cell
  value levels follow the value.id mode) – best for short labels;
  `"legend"`/`"legend.bottom"` keep names and print a label legend after
  the table. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- value.id:

  Character or NULL. Value-label display mode for both table axes:
  `"both"` (`"code: label"`), `"values"` (bare code), or `"labels"` (the
  label, degrading to the bare code where a code has none). `"legend"`
  and `"legend.bottom"` keep the bare code in the table and print a
  value-label legend after it (`"legend"` per-table, `"legend.bottom"`
  consolidated where multiple tables are produced). A no-op for axis
  variables with no value labels. NULL (default) defers to
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

Invisibly returns a list of class `jst_crosstab` containing: `observed`
(observed frequency table), `expected` (expected frequency table),
`adjusted_residuals` (matrix of adjusted standardized residuals), `n`
(total N), `model_frame` (the analysis data frame used for plotting),
`sample_info` (pipeline and missing data counts), and if `chisq = TRUE`:
`chi_square`, `df`, and `p` (the Pearson chi-square), `chi_method` (the
test's method string), and for 2x2 tables `chi_square_corrected` and
`p_corrected` (the Yates continuity-corrected values).

## Details

A red "Cross-Tabulation" title is printed first, followed by variable
labels (if present), then the table and optional test results.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Cross-tabulation only
jcrosstab(Education ~ Volunteer, data = community)
#> Cross-Tabulation
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No  1: Yes  Total 
#> -----------------------  -----  ------  ------
#> 1: Some high school      19     4       23    
#> (Row %)                  82.6%  17.4%   100.0%
#> 2: High school graduate  9      9       18    
#> (Row %)                  50.0%  50.0%   100.0%
#> 3: Some college          10     15      25    
#> (Row %)                  40.0%  60.0%   100.0%
#> 4: Bachelor's degree     7      6       13    
#> (Row %)                  53.8%  46.2%   100.0%
#> 5: Graduate degree       4      14      18    
#> (Row %)                  22.2%  77.8%   100.0%
#> Total                    49     48      97    
#> 
#> 

# With chi-square test
jcrosstab(Education ~ Volunteer, data = community, chisq = TRUE)
#> Cross-Tabulation
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No  1: Yes  Total 
#> -----------------------  -----  ------  ------
#> 1: Some high school      19     4       23    
#> (Row %)                  82.6%  17.4%   100.0%
#> 2: High school graduate  9      9       18    
#> (Row %)                  50.0%  50.0%   100.0%
#> 3: Some college          10     15      25    
#> (Row %)                  40.0%  60.0%   100.0%
#> 4: Bachelor's degree     7      6       13    
#> (Row %)                  53.8%  46.2%   100.0%
#> 5: Graduate degree       4      14      18    
#> (Row %)                  22.2%  77.8%   100.0%
#> Total                    49     48      97    
#> 
#> Chi-Square Test of Independence
#> Chi-Square  df   p    N 
#> ----------  --  ----  --
#>   16.407    4   .003  97
#> 

# With expected frequencies and column percentages
jcrosstab(Education ~ Volunteer, data = community,
          expected = TRUE, col.pct = TRUE)
#> Cross-Tabulation
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No   1: Yes  Total 
#> -----------------------  ------  ------  ------
#> 1: Some high school      19      4       23    
#> (Expected)               11.6    11.4    23.0  
#> (Row %)                  82.6%   17.4%   100.0%
#> (Col %)                  38.8%   8.3%    23.7% 
#> 2: High school graduate  9       9       18    
#> (Expected)               9.1     8.9     18.0  
#> (Row %)                  50.0%   50.0%   100.0%
#> (Col %)                  18.4%   18.8%   18.6% 
#> 3: Some college          10      15      25    
#> (Expected)               12.6    12.4    25.0  
#> (Row %)                  40.0%   60.0%   100.0%
#> (Col %)                  20.4%   31.2%   25.8% 
#> 4: Bachelor's degree     7       6       13    
#> (Expected)               6.6     6.4     13.0  
#> (Row %)                  53.8%   46.2%   100.0%
#> (Col %)                  14.3%   12.5%   13.4% 
#> 5: Graduate degree       4       14      18    
#> (Expected)               9.1     8.9     18.0  
#> (Row %)                  22.2%   77.8%   100.0%
#> (Col %)                  8.2%    29.2%   18.6% 
#> Total                    49      48      97    
#> (Col %)                  100.0%  100.0%  100.0%
#> 
#> 

# With adjusted standardized residuals (interpretation note at full output)
jcrosstab(Education ~ Volunteer, data = community, residuals = "adjusted")
#> Cross-Tabulation
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No   1: Yes  Total 
#> -----------------------  ------  ------  ------
#> 1: Some high school      19      4       23    
#> (Row %)                  82.6%   17.4%   100.0%
#> (Adj.Res.)               3.525   -3.525        
#> 2: High school graduate  9       9       18    
#> (Row %)                  50.0%   50.0%   100.0%
#> (Adj.Res.)               -0.048  0.048         
#> 3: Some college          10      15      25    
#> (Row %)                  40.0%   60.0%   100.0%
#> (Adj.Res.)               -1.221  1.221         
#> 4: Bachelor's degree     7       6       13    
#> (Row %)                  53.8%   46.2%   100.0%
#> (Adj.Res.)               0.258   -0.258        
#> 5: Graduate degree       4       14      18    
#> (Row %)                  22.2%   77.8%   100.0%
#> (Adj.Res.)               -2.660  2.660         
#> Total                    49      48      97    
#> 
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jcrosstab(Education ~ Volunteer)
#> Cross-Tabulation
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No  1: Yes  Total 
#> -----------------------  -----  ------  ------
#> 1: Some high school      19     4       23    
#> (Row %)                  82.6%  17.4%   100.0%
#> 2: High school graduate  9      9       18    
#> (Row %)                  50.0%  50.0%   100.0%
#> 3: Some college          10     15      25    
#> (Row %)                  40.0%  60.0%   100.0%
#> 4: Bachelor's degree     7      6       13    
#> (Row %)                  53.8%  46.2%   100.0%
#> 5: Graduate degree       4      14      18    
#> (Row %)                  22.2%  77.8%   100.0%
#> Total                    49     48      97    
#> 
#> 
jcrosstab(Education ~ Volunteer, chisq = TRUE)
#> Cross-Tabulation
#> Using default data frame: community
#> 
#> Case Processing    Excluded  Remaining
#>     Original              —        103
#>     Auto-listwise         6         97
#>     Analysis N            —         97
#> 
#> Missing-data breakdown  From 103    %
#>     Education
#>       Missing              6      5.8
#> 
#> ──────────────────────────────────────
#> 
#> Crosstab: Education by Volunteer
#> Education                0: No  1: Yes  Total 
#> -----------------------  -----  ------  ------
#> 1: Some high school      19     4       23    
#> (Row %)                  82.6%  17.4%   100.0%
#> 2: High school graduate  9      9       18    
#> (Row %)                  50.0%  50.0%   100.0%
#> 3: Some college          10     15      25    
#> (Row %)                  40.0%  60.0%   100.0%
#> 4: Bachelor's degree     7      6       13    
#> (Row %)                  53.8%  46.2%   100.0%
#> 5: Graduate degree       4      14      18    
#> (Row %)                  22.2%  77.8%   100.0%
#> Total                    49     48      97    
#> 
#> Chi-Square Test of Independence
#> Chi-Square  df   p    N 
#> ----------  --  ----  --
#>   16.407    4   .003  97
#> 
```
