# SPSS-like frequency tables for categorical variables

Prints an SPSS-style frequency table (Freq, Total %, Valid %, Cum. %)
for each variable supplied. Designed for use with unquoted variable
names, and also accepts a plain vector.

## Usage

``` r
jfreq(
  data,
  ...,
  subset = NULL,
  variable.id = NULL,
  value.id = NULL,
  case.processing.detail = NULL
)
```

## Arguments

- data:

  A data frame, or a vector.

- ...:

  Unquoted variable name(s) within `data` (ignored if `data` is a
  vector).

- subset:

  An optional unquoted logical expression (e.g. `Group == 1`) to subset
  cases for this call only. Applied after jcomplete and jsubset. Does
  not affect other function calls.

- variable.id:

  Character or NULL. Variable label display mode: one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`; `"labels"`
  uses each variable's label as its table caption (best for short
  labels); `"legend"` prints a label legend under each variable's own
  table; `"legend.bottom"` prints one consolidated legend after all
  tables. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `variable.id` setting. Not a logical. (Replaces the former inline
  Type/label block.)

- value.id:

  Character or NULL. Value-label display mode for the frequency-table
  valid rows: `"both"` (`"code: label"`), `"values"` (bare code), or
  `"labels"` (the label, degrading to the bare code where a code has
  none). `"legend"` and `"legend.bottom"` keep the bare code in the
  table and print a value-label legend after it (`"legend"` per-table,
  `"legend.bottom"` consolidated where multiple tables are produced). A
  no-op for variables with no value labels. NULL (default) defers to
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
  `value.id` setting. Not a logical.

- case.processing.detail:

  Accepted for API symmetry. jfreq's Case Processing Summary is
  top-table only (no missing-data breakdown), so this argument has no
  effect; per-variable code detail already appears in each variable's
  frequency table.

## Value

Invisibly returns a list of class `jst_freq` containing: `frequencies`
(named list of data frames, one per variable) and `sample_info`
(pipeline and missing data counts).

## Details

Output is structured consistently with
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md): a single
red "Frequencies" title is printed first, followed by the default-data
note (if a juse() default was used), any pipeline messages, and the Case
Processing Summary (when at least one pipeline stage was active for this
call). Each variable then gets its own block consisting of the variable
name on its own line, indented Type and Variable label lines (suppressed
when
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)'s
`variable.id` toggle is off), a blank line, and the frequency table. The
frequency table ends with a Total row showing the post-pipeline N.

For haven-labelled variables, value labels and numeric codes are
combined in the frequency table rows (e.g. `1: Strongly Oppose`). The
type line reports `haven_labelled (Categorical)` and suppresses the
uninformative `vctrs_vctr` class. Variable labels are shown for all
variable types, not only haven-labelled ones.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# With explicit data frame
jfreq(community, Region)
#> Frequencies
#> Region
#> 
#>           Freq  Total %  Valid %  Cum. %
#> --------  ----  -------  -------  ------
#> 1: North    27    26.21    26.21   26.21
#> 2: South    20    19.42    19.42   45.63
#> 3: East     31    30.10    30.10   75.73
#> 4: West     25    24.27    24.27  100.00
#>                                         
#> Total      103   100.00                 
#> 
#> 
jfreq(community, Region, Education)
#> Frequencies
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        103
#>     Remaining N         —        103
#> 
#> ────────────────────────────────────
#> 
#> Region
#> 
#>           Freq  Total %  Valid %  Cum. %
#> --------  ----  -------  -------  ------
#> 1: North    27    26.21    26.21   26.21
#> 2: South    20    19.42    19.42   45.63
#> 3: East     31    30.10    30.10   75.73
#> 4: West     25    24.27    24.27  100.00
#>                                         
#> Total      103   100.00                 
#> 
#> Education
#> 
#>                          Freq  Total %  Valid %  Cum. %
#> -----------------------  ----  -------  -------  ------
#> Valid                                                  
#> 1: Some high school        23    22.33    23.71   23.71
#> 2: High school graduate    18    17.48    18.56   42.27
#> 3: Some college            25    24.27    25.77   68.04
#> 4: Bachelor's degree       13    12.62    13.40   81.44
#> 5: Graduate degree         18    17.48    18.56  100.00
#>                                                        
#> Missing                                                
#> -99 ["Refused"]             3     2.91       --      --
#> -98 ["Don't know"]          3     2.91       --      --
#>                                                        
#> Total                     103   100.00                 
#> 
#> 

# Using juse() default
juse(community)
#> Default data frame set to: community
jfreq(Region)
#> Frequencies
#> Using default data frame: community
#> Region
#> 
#>           Freq  Total %  Valid %  Cum. %
#> --------  ----  -------  -------  ------
#> 1: North    27    26.21    26.21   26.21
#> 2: South    20    19.42    19.42   45.63
#> 3: East     31    30.10    30.10   75.73
#> 4: West     25    24.27    24.27  100.00
#>                                         
#> Total      103   100.00                 
#> 
#> 
jfreq(Region, Education)
#> Frequencies
#> Using default data frame: community
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        103
#>     Remaining N         —        103
#> 
#> ────────────────────────────────────
#> 
#> Region
#> 
#>           Freq  Total %  Valid %  Cum. %
#> --------  ----  -------  -------  ------
#> 1: North    27    26.21    26.21   26.21
#> 2: South    20    19.42    19.42   45.63
#> 3: East     31    30.10    30.10   75.73
#> 4: West     25    24.27    24.27  100.00
#>                                         
#> Total      103   100.00                 
#> 
#> Education
#> 
#>                          Freq  Total %  Valid %  Cum. %
#> -----------------------  ----  -------  -------  ------
#> Valid                                                  
#> 1: Some high school        23    22.33    23.71   23.71
#> 2: High school graduate    18    17.48    18.56   42.27
#> 3: Some college            25    24.27    25.77   68.04
#> 4: Bachelor's degree       13    12.62    13.40   81.44
#> 5: Graduate degree         18    17.48    18.56  100.00
#>                                                        
#> Missing                                                
#> -99 ["Refused"]             3     2.91       --      --
#> -98 ["Don't know"]          3     2.91       --      --
#>                                                        
#> Total                     103   100.00                 
#> 
#> 

# With a vector directly
jfreq(community$Region)
#> Frequencies
#> Region
#> 
#>           Freq  Total %  Valid %  Cum. %
#> --------  ----  -------  -------  ------
#> 1: North    27    26.21    26.21   26.21
#> 2: South    20    19.42    19.42   45.63
#> 3: East     31    30.10    30.10   75.73
#> 4: West     25    24.27    24.27  100.00
#>                                         
#> Total      103   100.00                 
#> 
#> 
```
