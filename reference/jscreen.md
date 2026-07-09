# Data screening overview

Provides a quick overview of a data frame for screening. A red "Data
Screening" title is printed first, then a short header block (case and
variable counts, cases with missing data, variables with outliers),
followed by up to three tables: a Variable Types table (Base R storage
type, the jstats analysis-role class, an optional sub-class, an optional
classification source, distinct-value counts, and optional central-
tendency columns), a Missing Data & Outliers table, and – when variable
labels are shown – a Variable Labels table last. Handles haven-labelled
and date/time variables gracefully.

## Usage

``` r
jscreen(
  data,
  ...,
  outlier.sd = 3,
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  types = TRUE,
  issues = TRUE,
  r.type = FALSE,
  stats = FALSE,
  digits = NULL
)
```

## Arguments

- data:

  A data frame.

- ...:

  Optional unquoted variable names to screen. If omitted, all variables
  in the data frame are screened.

- outlier.sd:

  Numeric. Number of standard deviations from the mean to flag as
  potential outliers (Numeric-class variables only). Default is 3.

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  shows labels in each table's Variable column (best for short labels);
  `"legend"` and `"legend.bottom"` keep names and print a label legend
  after the tables. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical.

- value.id:

  Not supported by `jscreen()`. The function does not display value
  labels, so passing this argument is an error. It exists only to return
  a clear message rather than misreporting the token as a missing
  variable. Leave at NULL (default).

- types:

  Logical. If TRUE (default), prints the Variable Types table. Set FALSE
  to suppress it.

- issues:

  Logical. If TRUE (default), prints the Missing Data & Outliers table,
  which lists only the variables that actually have missing data or
  flagged outliers (clean variables are omitted). Set FALSE to suppress
  the table entirely. Suppressing `types`, `issues`, and `labels`
  together leaves only the header block.

- r.type:

  Logical. If TRUE, adds a "Base R Type" column (numeric /
  haven_labelled / factor / character / date-time) to the Variable Types
  table, showing each variable's storage type alongside its jstats
  class. Default is FALSE: the storage type is expert detail (its main
  signal is "this variable carries value labels / came from SPSS or
  Stata"), so it is opt-in rather than shown by default. The returned
  data frame always includes it regardless of this setting.

- stats:

  Logical or character. Adds central-tendency columns to the Variable
  Types table for numeric-like variables. FALSE (default) shows none;
  TRUE shows both Mean and Median; `"mean"` or `"median"` shows only
  that one. Numeric and Count variables show both; a numeric dichotomy
  shows its raw mean and a blank median; N-category and other
  non-numeric variables are blank. The returned data frame always
  includes Mean and Median regardless of this setting.

- digits:

  Integer or NULL. Number of decimal places for the Mean and Median
  columns. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `digits` setting (default 3).

## Value

Invisibly returns a data frame of the screening results, with one row
per variable and columns including the Base R type, the jstats `Class`
and `SubClass`, the classification `Source` ("registered" or
"structural"), distinct-value count, missing count and percentage, the
outlier count (NA for non-Numeric variables), and the `Mean` and
`Median` (NA where not meaningful: Median is NA for dichotomies, and
both are NA for non-numeric-like variables). The returned values are the
raw counts; only the printed tables blank zeros and omit clean rows.

## Details

The jstats Class column reports how the package treats each variable in
analyses (Numeric, Categorical, Numbers-as-text, Date-time,
Unsupported), in contrast to the Base R Type column's storage view; the
same classification gates outlier screening, so only Numeric-class
variables are SD-screened and the Outliers cell is left blank for the
rest. Zero counts are shown blank so only affected variables carry
numbers; a column (or the whole Missing/Outliers table) is omitted
entirely when nothing is flagged, and the header count lines explain the
omission.

When at least one variable's class comes from a registration (jnumeric,
jcount, or jdummy) rather than the structural guess, a Source column
appears. It reads as an exception-marker: "registered" is shown against
the registered variables and the structurally classified rows are left
blank, so the registrations stand out at a glance. (The returned data
frame still records the literal tier for every row.) Set `stats = TRUE`
(or "mean" / "median") to add central-tendency columns for the
numeric-like variables: Numeric and Count variables show Mean and
Median, while a numeric dichotomy shows the raw mean of its stored codes
and a blank median. A numeric dichotomy coded other than 0/1 (e.g. the
1/2 Group-4 coding) is flagged with a "\*" on its sub-class cell, since
its raw mean is not a proportion; the marker shows even when `stats` is
off, surfacing the recode need.

When variable names are supplied, only those variables are screened.
When omitted, all variables in the data frame are screened. If a
`subset` expression references variables not already in the screening
list, they are included automatically.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jscreen(community)
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Unique Values
#> --------------  ------------  ----------  -------------
#> RespondentID    Categorical   identifier            103
#> Income          Numeric                              49
#> Education       Categorical   5-category              5
#> Age             Numeric                              41
#> WellbeingScore  Numeric                              41
#> Volunteer       Categorical   dichotomy               2
#> OwnsHome        Categorical   dichotomy*              2
#> Smoker          Categorical   dichotomy               2
#> CommuteTime     Numeric                              42
#> Region          Categorical   4-category              4
#> Environment1    Categorical   Likert                  5
#> Environment2    Categorical   Likert                  5
#> Environment3    Categorical   Likert                  5
#> Environment4    Categorical   Likert                  5
#> Environment5    Categorical   Likert                  5
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable      Missing  % Missing
#> ------------  -------  ---------
#> Income              6        5.8
#> Education           6        5.8
#> Smoker              5        4.9
#> Environment1       12       11.7
#> Environment3       12       11.7
#> 
jscreen(community, outlier.sd = 2.5)
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 2 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Unique Values
#> --------------  ------------  ----------  -------------
#> RespondentID    Categorical   identifier            103
#> Income          Numeric                              49
#> Education       Categorical   5-category              5
#> Age             Numeric                              41
#> WellbeingScore  Numeric                              41
#> Volunteer       Categorical   dichotomy               2
#> OwnsHome        Categorical   dichotomy*              2
#> Smoker          Categorical   dichotomy               2
#> CommuteTime     Numeric                              42
#> Region          Categorical   4-category              4
#> Environment1    Categorical   Likert                  5
#> Environment2    Categorical   Likert                  5
#> Environment3    Categorical   Likert                  5
#> Environment4    Categorical   Likert                  5
#> Environment5    Categorical   Likert                  5
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 2.5 SD from mean)
#> Variable        Missing  % Missing  Outliers
#> --------------  -------  ---------  --------
#> Income                6        5.8          
#> Education             6        5.8          
#> Age                                        1
#> WellbeingScore                             1
#> Smoker                5        4.9          
#> Environment1         12       11.7          
#> Environment3         12       11.7          
#> 

# Show the Base R storage type column
jscreen(community, r.type = TRUE)
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        Base R Type     jstats Class  Sub-class   Unique Values
#> --------------  --------------  ------------  ----------  -------------
#> RespondentID    character       Categorical   identifier            103
#> Income          haven_labelled  Numeric                              49
#> Education       haven_labelled  Categorical   5-category              5
#> Age             numeric         Numeric                              41
#> WellbeingScore  numeric         Numeric                              41
#> Volunteer       haven_labelled  Categorical   dichotomy               2
#> OwnsHome        haven_labelled  Categorical   dichotomy*              2
#> Smoker          haven_labelled  Categorical   dichotomy               2
#> CommuteTime     numeric         Numeric                              42
#> Region          haven_labelled  Categorical   4-category              4
#> Environment1    haven_labelled  Categorical   Likert                  5
#> Environment2    haven_labelled  Categorical   Likert                  5
#> Environment3    haven_labelled  Categorical   Likert                  5
#> Environment4    haven_labelled  Categorical   Likert                  5
#> Environment5    haven_labelled  Categorical   Likert                  5
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable      Missing  % Missing
#> ------------  -------  ---------
#> Income              6        5.8
#> Education           6        5.8
#> Smoker              5        4.9
#> Environment1       12       11.7
#> Environment3       12       11.7
#> 

# Add Mean and Median columns for numeric-like variables
jscreen(community, stats = TRUE)
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Unique Values       Mean  Median
#> --------------  ------------  ----------  -------------  ---------  ------
#> RespondentID    Categorical   identifier            103                   
#> Income          Numeric                              49  49855.670   49000
#> Education       Categorical   5-category              5                   
#> Age             Numeric                              41     40.650      40
#> WellbeingScore  Numeric                              41     50.893      50
#> Volunteer       Categorical   dichotomy               2      0.476        
#> OwnsHome        Categorical   dichotomy*              2      1.534        
#> Smoker          Categorical   dichotomy               2      0.337        
#> CommuteTime     Numeric                              42     30.738      30
#> Region          Categorical   4-category              4                   
#> Environment1    Categorical   Likert                  5                   
#> Environment2    Categorical   Likert                  5                   
#> Environment3    Categorical   Likert                  5                   
#> Environment4    Categorical   Likert                  5                   
#> Environment5    Categorical   Likert                  5                   
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable      Missing  % Missing
#> ------------  -------  ---------
#> Income              6        5.8
#> Education           6        5.8
#> Smoker              5        4.9
#> Environment1       12       11.7
#> Environment3       12       11.7
#> 

# Suppress tables (header block only)
jscreen(community, types = FALSE, issues = FALSE)
#> Data Screening
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jscreen()
#> Data Screening
#> Using default data frame: community
#>   Cases: 103 
#>   Variables: 15 
#>   Cases with missing data: 34 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Unique Values
#> --------------  ------------  ----------  -------------
#> RespondentID    Categorical   identifier            103
#> Income          Numeric                              49
#> Education       Categorical   5-category              5
#> Age             Numeric                              41
#> WellbeingScore  Numeric                              41
#> Volunteer       Categorical   dichotomy               2
#> OwnsHome        Categorical   dichotomy*              2
#> Smoker          Categorical   dichotomy               2
#> CommuteTime     Numeric                              42
#> Region          Categorical   4-category              4
#> Environment1    Categorical   Likert                  5
#> Environment2    Categorical   Likert                  5
#> Environment3    Categorical   Likert                  5
#> Environment4    Categorical   Likert                  5
#> Environment5    Categorical   Likert                  5
#> * coded other than 0/1; mean is not a proportion
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable      Missing  % Missing
#> ------------  -------  ---------
#> Income              6        5.8
#> Education           6        5.8
#> Smoker              5        4.9
#> Environment1       12       11.7
#> Environment3       12       11.7
#> 
jscreen(Income, Age, WellbeingScore)
#> Data Screening
#> Using default data frame: community
#>   Cases: 103 
#>   Variables: 3 
#>   Cases with missing data: 6 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Unique Values
#> --------------  ------------  -------------
#> Income          Numeric                  49
#> Age             Numeric                  41
#> WellbeingScore  Numeric                  41
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable  Missing  % Missing
#> --------  -------  ---------
#> Income          6        5.8
#> 
jscreen(Income, Age, WellbeingScore, subset = Volunteer == 1)
#> Data Screening
#> Using default data frame: community
#>   Cases: 49 
#>   Variables: 4 
#>   Cases with missing data: 4 
#>   Variables with outliers: 0 
#> 
#> Variable Types
#> Variable        jstats Class  Sub-class   Unique Values
#> --------------  ------------  ----------  -------------
#> Income          Numeric                              30
#> Age             Numeric                              31
#> WellbeingScore  Numeric                              25
#> Volunteer       Categorical   1-category              1
#> 
#> Missing Data & Outliers (outliers > 3 SD from mean)
#> Variable  Missing  % Missing
#> --------  -------  ---------
#> Income          4        8.2
#> 
```
