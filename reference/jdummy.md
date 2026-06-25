# Register categorical variables for dummy coding in regression

`jdummy()` registers a categorical variable so that
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) automatically
expands it into dummy (indicator) variables when it appears in a
regression formula. The original data frame is never modified. Several
variables can be registered in one call; the `ref` setting then applies
to each of them.

Registrations are stored per dataset, so switching
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) between
datasets preserves each dataset's registrations independently.

## Usage

``` r
jdummy(
  data,
  ...,
  ref = "first",
  show = FALSE,
  remove = FALSE,
  clear.all = FALSE,
  max.categories = 20L
)
```

## Arguments

- data:

  A data frame, or omit to use the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.
  `jdummy(NULL)` clears the dummy registrations on the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  data frame (or, with no default set, the only frame that carries them;
  if several do, it asks rather than wiping all).

- ...:

  One or more unquoted variable names to register. Omit (along with
  data) to display all current registrations. A lone `NULL` in the
  variable slot – `jdummy(data, NULL)` – clears that frame's dummy
  registrations.

- ref:

  The reference category (excluded from the regression model). Can be a
  numeric code, a quoted label name, or `first` (default) or `last`.
  Applied to every variable named in the call; to use different
  reference categories, register the variables in separate calls.

- show:

  Logical. If `TRUE`, prints the dummy coding scheme table showing the
  pattern of 0s and 1s. Default is `FALSE`.

- remove:

  Logical. If `TRUE`, removes the registration for the specified
  variable(s). Default is `FALSE`.

- clear.all:

  Logical. If `TRUE`, clears dummy registrations on every data frame
  that carries them. Default is `FALSE`.

- max.categories:

  Integer. Maximum number of categories a variable may have to be
  dummy-coded; a variable with more raises an error. Raise it to
  dummy-code a higher-cardinality variable. Default `20L`.

## Value

Invisibly returns `NULL`. Called for its side effect.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# \donttest{
juse(community)
#> Default data frame set to: community
jdummy(Region)                       # Register, first category as reference
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_North
#>   Dummy variables: Region_South, Region_East, Region_West
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jdummy(Region, Education)            # Register several at once
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_North
#>   Dummy variables: Region_South, Region_East, Region_West
#>   Cases: 100 (0 missing)
#> 
#>   Variable: Education (haven_labelled)
#>   Reference category: Education_Some_high_school
#>   Dummy variables: Education_High_school_graduate, Education_Some_college, Education_Bachelor_s_degree, Education_Graduate_degree
#>   Cases: 100 (6 missing)
#> 
#> Note: registrations are stored for this session only.
#> To keep them across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registrations:
#>   community <- jload("community.rds")
jdummy(Region, ref = "last")         # Last category as reference
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_West
#>   Dummy variables: Region_North, Region_South, Region_East
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jdummy(Region, ref = 4)              # Reference by numeric code
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_West
#>   Dummy variables: Region_North, Region_South, Region_East
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jdummy(Region, ref = "East")         # Reference by value label
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_East
#>   Dummy variables: Region_North, Region_South, Region_West
#>   Cases: 100 (0 missing)
#> 
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jdummy(Region, show = TRUE)          # Show coding scheme
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_East
#>   Dummy variables: Region_North, Region_South, Region_West
#>   Cases: 100 (0 missing)
#> 
#>   Dummy Coding Scheme:
#> 
#>                      Region_North  Region_South  Region_East*  Region_West
#>     ---------------  ------------  ------------  ------------  -----------
#>     1: Region_North             1             0             0            0
#>     2: Region_South             0             1             0            0
#>     3: Region_East*             0             0             1            0
#>     4: Region_West              0             0             0            1
#> 
#>     * Reference category
#> 
jdummy(Region, show = "all")         # Full scheme (for many categories)
#> Dummy Variable Registration
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: Region_East
#>   Dummy variables: Region_North, Region_South, Region_West
#>   Cases: 100 (0 missing)
#> 
#>   Dummy Coding Scheme:
#> 
#>                      Region_North  Region_South  Region_East*  Region_West
#>     ---------------  ------------  ------------  ------------  -----------
#>     1: Region_North             1             0             0            0
#>     2: Region_South             0             1             0            0
#>     3: Region_East*             0             0             1            0
#>     4: Region_West              0             0             0            1
#> 
#>     * Reference category
#> 
jdummy()                             # Show all registrations
#> Dummy Variable Registrations
#> Using default data frame: community
#> 
#>   Variable: Region (haven_labelled)
#>   Reference category: 3: Region_East
#>   Dummy variables: Region_North, Region_South, Region_West
#>   Cases: 100 (0 missing)
#> 
#>   Variable: Education (haven_labelled)
#>   Reference category: 1: Education_Some_high_school
#>   Dummy variables: Education_High_school_graduate, Education_Some_college, Education_Bachelor_s_degree, Education_Graduate_degree
#>   Cases: 100 (6 missing)
#> 
jdummy(Region, remove = TRUE)        # Remove one registration
#> Dummy registration removed for 'Region' in community.
jdummy(community, NULL)              # Clear community's dummy registrations
#> Dummy registrations cleared for community: Education.
jdummy(NULL)                         # Clear the default frame's (or ask)
#> No dummy registrations to clear for community (the default data frame).
jdummy(clear.all = TRUE)             # Clear every frame's dummy registrations
#> No dummy registrations to clear.
# }
```
