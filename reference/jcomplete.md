# Set a listwise complete-case filter for matching N across analyses

`jcomplete()` registers a set of variables and activates a listwise
deletion filter that excludes any case with a missing value on any of
the registered variables. This ensures that all subsequent analyses use
the same set of complete cases, which is essential when preliminary
analyses need to match the N of a final regression model.

The setting is stored per dataset, so switching
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) between
datasets preserves each dataset's setting independently.

The jcomplete filter applies whenever the matching dataset is used,
regardless of whether it was supplied via
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) or
specified explicitly in a function call. To bypass temporarily without
losing the setting, use `jcomplete(off)` before the analysis and
`jcomplete(on)` afterward. This matches the SPSS USE ALL / FILTER
convention.

## Usage

``` r
jcomplete(data, ..., preview = FALSE, console = FALSE, non.deletes = FALSE)
```

## Arguments

- data:

  A data frame. If omitted, uses the default set by
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md). Pass
  `NULL` to clear the filter entirely. Pass the bare word `off` to
  deactivate, or `on` to reactivate. Call with no arguments to check the
  current status.

- ...:

  Unquoted variable names to include in the listwise check.

- preview:

  Logical. If `TRUE`, open a viewer (RStudio data tab) showing the rows
  the listwise filter will drop, with a leading `Row` column (original
  data position) and a trailing `DeletionCheck` flag (1 = the row will
  be dropped). May be used on its own to preview the already-set filter
  without re-listing the variables (`jcomplete(preview = TRUE)`).
  Default `FALSE`.

- console:

  Logical or numeric. Print the dropped rows to the console. `TRUE`
  prints the first 10; a number prints that many. Independent of
  `preview`: on its own it prints to the console without opening the
  viewer; combine with `preview = TRUE` to get both. The console listing
  is always limited to the dropped rows so it cannot flood the console.
  Default `FALSE`.

- non.deletes:

  Logical. If `TRUE`, the viewer shows every case (with `DeletionCheck`
  marking which will drop) rather than only the dropped rows. Affects
  the viewer only; the console listing stays deleted-rows-only. Default
  `FALSE`.

## Value

Invisibly returns `NULL`. When a preview is requested, invisibly returns
the previewed data frame instead, so it can be captured (e.g.
`jcomplete_rows <- jcomplete(preview = TRUE)`).

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# \donttest{
juse(community)
#> Default data frame set to: community
jcomplete(Income, Education, Age)
#> Listwise Case Filter
#> Using default data frame: community
#> 
#> Variable     N  Missing  % Missing
#> ---------  ---  -------  ---------
#> Income     100        6  6.0%     
#> Education  100        6  6.0%     
#> Age        100        0  0.0%     
#> 
#>   Complete cases: 88 of 100 (88.0%)
#>   Listwise filter activated — 12 cases will be excluded from subsequent analyses.
jdesc(Age)                     # Uses only complete cases on those 3 vars
#> Descriptive Statistics
#> Using default data frame: community
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —        100
#>     jcomplete          12         88  Income, Education, +1 more
#>     Remaining N         —         88
#> 
#> ────────────────────────────────────────────────────────────────
#> 
#> 
#> Variable  Total  Non_missing  Min  Max    Mean      SD
#> --------  -----  -----------  ---  ---  ------  ------
#> Age          88           88   18   71  41.125  11.794
#> 
jcomplete(Income, Education, Age, preview = TRUE)  # Set and preview together
#> Listwise Case Filter
#> Using default data frame: community
#> 
#> Variable     N  Missing  % Missing
#> ---------  ---  -------  ---------
#> Income     100        6  6.0%     
#> Education  100        6  6.0%     
#> Age        100        0  0.0%     
#> 
#>   Complete cases: 88 of 100 (88.0%)
#>   Listwise filter activated — 12 cases will be excluded from subsequent analyses.
#> jcomplete Preview — rows scheduled for deletion
#> Row  Income  Education  Age  DeletionCheck
#> ---  ------  ---------  ---  -------------
#>   2                  4   32              1
#>  13                  3   33              1
#>  19   14000              24              1
#>  27                  5   49              1
#>  30                  2   58              1
#>  35   56000              33              1
#>  41                  2   26              1
#>  45   46000              29              1
#>  48   55000              49              1
#>  74   57000              36              1
#> 
#>   Showing the first 10 of 12 dropped rows.
#> (The preview viewer needs an interactive RStudio session; showing the first 10 in the console instead.)
jcomplete(preview = TRUE)      # Preview the already-set filter (viewer)
#> jcomplete Preview — rows scheduled for deletion
#> Row  Income  Education  Age  DeletionCheck
#> ---  ------  ---------  ---  -------------
#>   2                  4   32              1
#>  13                  3   33              1
#>  19   14000              24              1
#>  27                  5   49              1
#>  30                  2   58              1
#>  35   56000              33              1
#>  41                  2   26              1
#>  45   46000              29              1
#>  48   55000              49              1
#>  74   57000              36              1
#> 
#>   Showing the first 10 of 12 dropped rows.
#> (The preview viewer needs an interactive RStudio session; showing the first 10 in the console instead.)
jcomplete(preview = TRUE, non.deletes = TRUE)  # Viewer shows all cases
#> jcomplete Preview — rows scheduled for deletion
#> Row  Income  Education  Age  DeletionCheck
#> ---  ------  ---------  ---  -------------
#>   2                  4   32              1
#>  13                  3   33              1
#>  19   14000              24              1
#>  27                  5   49              1
#>  30                  2   58              1
#>  35   56000              33              1
#>  41                  2   26              1
#>  45   46000              29              1
#>  48   55000              49              1
#>  74   57000              36              1
#> 
#>   Showing the first 10 of 12 dropped rows.
#> (The preview viewer needs an interactive RStudio session; showing the first 10 in the console instead.)
jcomplete(console = 10)        # Console only -- first 10 dropped rows
#> jcomplete Preview — rows scheduled for deletion
#> Row  Income  Education  Age  DeletionCheck
#> ---  ------  ---------  ---  -------------
#>   2                  4   32              1
#>  13                  3   33              1
#>  19   14000              24              1
#>  27                  5   49              1
#>  30                  2   58              1
#>  35   56000              33              1
#>  41                  2   26              1
#>  45   46000              29              1
#>  48   55000              49              1
#>  74   57000              36              1
#> 
#>   Showing the first 10 of 12 dropped rows. Use preview = TRUE to see them all in the viewer.
jcomplete(preview = TRUE, console = 25)        # Viewer and console
#> jcomplete Preview — rows scheduled for deletion
#> Row  Income  Education  Age  DeletionCheck
#> ---  ------  ---------  ---  -------------
#>   2                  4   32              1
#>  13                  3   33              1
#>  19   14000              24              1
#>  27                  5   49              1
#>  30                  2   58              1
#>  35   56000              33              1
#>  41                  2   26              1
#>  45   46000              29              1
#>  48   55000              49              1
#>  74   57000              36              1
#>  84                  2   32              1
#>  95   58000              46              1
jcomplete(off)                 # Deactivate
#> jcomplete deactivated for community.
jcomplete(on)                  # Reactivate
#> jcomplete reactivated for community: Income, Education, Age
jcomplete()                    # Check status
#> jcomplete active for community: Income, Education, Age (88 of 100 complete cases)
jcomplete(NULL)                # Clear entirely
#> jcomplete cleared for community (had: Income, Education, Age).
# }
```
