# Compute a row-wise mean across multiple variables

`javg()` computes the mean of values across multiple variables for each
case (row) in the data frame. This is typically used to create scale
means from a set of related items.

By default, cases with any missing values receive `NA`. Use the
`min.valid` argument to allow partial means — for example,
`min.valid = 1` computes the mean of available values as long as at
least one item is non-missing.

By default, the denominator is the number of non-missing values for each
case. Use `fixed = TRUE` to always divide by the total number of
variables regardless of missing values.

Variables can be listed individually or using colon notation to select a
range of consecutive columns (e.g. `Attitude1:Attitude6`).

## Usage

``` r
javg(data, ..., min.valid = NULL, fixed = FALSE, var.label = NULL)
```

## Arguments

- data:

  A data frame, or omit to use the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.

- ...:

  Unquoted variable names. Use colon notation (e.g.
  `Attitude1:Attitude6`) to select a range of consecutive columns.

- min.valid:

  Integer (optional). The minimum number of non-missing values required
  to compute a mean. If a case has fewer non-missing values, the result
  is `NA`. If omitted, all values must be non-missing (equivalent to
  setting min.valid to the number of variables).

- fixed:

  Logical. If `FALSE` (default), the denominator for each case is the
  number of non-missing values (i.e. the mean adjusts for missing data).
  If `TRUE`, the denominator is always the total number of variables
  (i.e. missing values effectively count as zero).

- var.label:

  Character string (optional). A variable label to attach to the result.
  If omitted, an auto-generated label is used.

## Value

A numeric vector the same length as `nrow(data)`, suitable for assigning
to a new column: `MyData$ScaleMean <- javg(Var1, Var2, Var3)`.

## See also

[`jsum`](https://jma61.github.io/jstats/reference/jsum.md) for computing
row-wise sums.

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Set the default data frame (so you can omit it in function calls)
juse(community)
#> Default data frame set to: community

# Mean of three variables (all must be non-missing)
community$EnvAvg <- javg(Environment1, Environment3, Environment4)
#> Mean of 3 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 3.175.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Mean with partial data allowed (at least 2 non-missing)
community$EnvAvg <- javg(Environment1, Environment3, Environment4,
                         min.valid = 2)
#> Mean of 3 variables computed for 103 cases (min.valid = 2: 14 cases used partial data, 5 set to NA due to missing values).
#> Mean of the new variable: 3.180.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Mean using colon range for consecutive columns
community$ScaleMean <- javg(Environment1:Environment5)
#> Mean of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 3.031.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Mix colon ranges and explicit names (e.g. after reverse-coding an item)
community$Environment2R <- jrecode(community, Environment2,
                                   map = "1=5; 2=4; 3=3; 4=2; 5=1")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   community$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.
community$ScaleMean <- javg(Environment1, Environment2R,
                            Environment3:Environment5)
#> Mean of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 3.083.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Fixed denominator (always divide by total number of variables)
community$EnvAvg <- javg(Environment1, Environment3, Environment4,
                         min.valid = 2, fixed = TRUE)
#> Mean of 3 variables computed for 103 cases (fixed denominator) (min.valid = 2: 14 cases used partial data, 5 set to NA due to missing values).
#> Mean of the new variable: 3.027.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# With a custom variable label
community$ScaleMean <- javg(Environment1:Environment5,
                            var.label = "Environment Scale Mean")
#> Mean of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 3.031.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# With an explicit data frame (instead of using juse default)
community$EnvAvg <- javg(community, Environment1, Environment3,
                         Environment4)
#> Mean of 3 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 3.175.
#> 
#> Note: javg() returns the scores; assign them to a column to keep them:
#>   community$<name> <- javg(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Not normally needed. You'd clear a default or registration only to
# undo a mistake, or -- as in this example -- to reset state for testing.
juse(NULL)
#> Default data frame cleared.
```
