# Set or display the default data frame for jstats functions

`juse()` sets a default data frame that will be used automatically by
all jstats functions when the `data` argument is omitted. This reduces
typing and makes interactive use more convenient.

The function stores the *name* of the data frame, not a copy of the
data. This means any changes you make to the data frame (adding columns,
recoding variables, etc.) are automatically reflected in subsequent
function calls.

## Usage

``` r
juse(data)
```

## Arguments

- data:

  A data frame (unquoted). If omitted, prints the current default. Use
  `juse(NULL)` to clear the default.

## Value

Invisibly returns `NULL`. Called for its side effect of setting,
displaying, or clearing the default data frame.

## Note

`juse()` stores the *name* of the data frame, not a copy of the data.
This means any changes you make to the data frame (adding columns,
recoding variables, etc.) are automatically reflected in subsequent
function calls. This differs from base R's
[`attach()`](https://rdrr.io/r/base/attach.html), which creates a
snapshot that can become stale after modifications. `juse()` is the
recommended approach for this package.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
juse(community)              # Set community as the default
#> Default data frame set to: community
juse()                       # Display current default
#> Current default data frame: community
jdesc(Age, WellbeingScore)   # Uses community automatically
#> Descriptive Statistics
#> Using default data frame: community
#> 
#> Variable        Total  Non_missing  Min  Max    Mean      SD
#> --------------  -----  -----------  ---  ---  ------  ------
#> Age               103          103   18   71  40.650  11.620
#> WellbeingScore    103          103   25   81  50.893  11.481
#> 
juse(NULL)                   # Clear the default
#> Default data frame cleared.
```
