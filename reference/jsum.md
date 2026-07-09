# Compute a row-wise sum across multiple variables

`jsum()` computes the sum of values across multiple variables for each
case (row) in the data frame. This is typically used to create composite
scores from a set of related items (e.g. summing 6 survey items into a
total scale score).

By default, cases with any missing values receive `NA`. Use the
`min.valid` argument to allow partial sums — for example,
`min.valid = 1` returns the sum of available values as long as at least
one item is non-missing.

Variables can be listed individually or using colon notation to select a
range of consecutive columns (e.g. `Attitude1:Attitude6`).

## Usage

``` r
jsum(data, ..., min.valid = NULL, var.label = NULL)
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
  to compute a sum. If a case has fewer non-missing values, the result
  is `NA`. If omitted, all values must be non-missing (equivalent to
  setting min.valid to the number of variables).

- var.label:

  Character string (optional). A variable label to attach to the result.
  If omitted, an auto-generated label is used.

## Value

A numeric vector the same length as `nrow(data)`, suitable for assigning
to a new column: `MyData$Total <- jsum(Var1, Var2, Var3)`.

## See also

[`javg`](https://jma61.github.io/jstats/reference/javg.md) for computing
row-wise means.

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Set the default data frame (so you can omit it in function calls)
juse(community)
#> Default data frame set to: community

# Sum three variables (all must be non-missing)
community$EnvTotal <- jsum(Environment1, Environment3, Environment4)
#> Sum of 3 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 9.524.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Sum with partial data allowed (at least 2 non-missing)
community$EnvTotal <- jsum(Environment1, Environment3, Environment4,
                           min.valid = 2)
#> Sum of 3 variables computed for 103 cases (min.valid = 2: 14 cases used partial data, 5 set to NA due to missing values).
#> Mean of the new variable: 9.082.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Sum using colon range for consecutive columns
community$EnvTotal <- jsum(Environment1:Environment5)
#> Sum of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 15.155.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Mix colon ranges and explicit names (e.g. after reverse-coding an item)
community$Environment2R <- jrecode(community, Environment2,
                                   map = "1=5; 2=4; 3=3; 4=2; 5=1")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   community$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.
community$ScaleTotal <- jsum(Environment1, Environment2R,
                             Environment3:Environment5)
#> Sum of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 15.417.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# With a custom variable label
community$ScaleTotal <- jsum(Environment1:Environment5,
                             var.label = "Environment Scale Total")
#> Sum of 5 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 15.155.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# With an explicit data frame (instead of using juse default)
community$EnvTotal <- jsum(community, Environment1, Environment3,
                           Environment4)
#> Sum of 3 variables computed for 103 cases (19 set to NA due to missing values).
#> Mean of the new variable: 9.524.
#> 
#> Note: jsum() returns the totals; assign them to a column to keep them:
#>   community$<name> <- jsum(...)
#> For the full distribution (min, max, SD), run jdesc() on the new column.

# Not normally needed. You'd clear a default or registration only to
# undo a mistake, or -- as in this example -- to reset state for testing.
juse(NULL)
#> Default data frame cleared.
```
