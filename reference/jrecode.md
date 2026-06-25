# Recode a variable with explicit value mapping and optional labels

`jrecode()` recodes a variable using a simple map string that specifies
how old values should be converted to new values. It is designed for
situations where you need to collapse categories, change numeric codes,
or recode dichotomies. Variable and value labels are handled
automatically.

Map and labels rules can also produce missing values: plain system NA
via the `NA` / `System` / `SYSMIS` aliases, or Stata-style tagged
missing values (`.a` through `.z`) when the active convention is Stata.
See *Missing values in the map* below for the canonical patterns under
each convention.

## Usage

``` r
jrecode(data, orig.var, map, labels = NULL, convention = NULL)
```

## Arguments

- data:

  A data frame containing the original variable.

- orig.var:

  The variable to recode (unquoted, e.g. `AgeGroup`).

- map:

  A quoted string specifying the recode rules, using the format
  `"old=new"` with rules separated by semicolons. Multiple old values
  mapping to the same new value are separated by commas on the left
  side.

  An optional `else` clause controls what happens to values not covered
  by the map:

  - No else clause: the function stops with a message if any values are
    left unmapped, so you can fix the map before proceeding.

  - `else=NA` (also `else=System` or `else=SYSMIS`): unmapped values are
    deliberately set to system NA.

  - `else=copy`: unmapped values are carried across unchanged.

  - `else=.a` (or any Stata-style missing-value token, Stata convention
    only): unmapped values are set to that Stata-style missing value.

  Individual values can also be mapped to system NA using the same
  aliases: `"-5=NA"`, `"-5=System"`, or `"-5=SYSMIS"`.

  Under Stata convention, values can be mapped to Stata-style
  missing-value tokens: `"-99=.a; -98=.b"`.

  Examples:

  - `"1=1; 2=0"`

  - `"1=1; 2,3=2; 4,5=3; else=NA"`

  - `"1=1; 2=0; else=copy"`

  - `"-5=System; else=copy"`

  - `"3=1; 4=2; else=.a"` (Stata convention only)

- labels:

  Optional. A quoted string specifying value labels for the new
  variable, using the format `"code=Label Text"` with rules separated by
  semicolons. If supplied, these labels are used as-is.

  The left side of each rule may be a numeric code or, under Stata
  convention, a Stata-style missing-value token (`.a` through `.z`).
  Tagged-NA labels are stored on the tag itself, not on a numeric code.

  If omitted, the function attempts to transfer value labels
  automatically from the original variable. This works when the original
  variable has value labels and the mapping is one-to-one (no categories
  are collapsed). When categories are collapsed, labels cannot be
  transferred automatically and a note is printed.

  Example: `"1=Male; 0=Female"` or `".a=Refused; .b=Don't know"`.

- convention:

  Optional. One of `"spss"`, `"stata"`, or `NULL` (default). Controls
  whether Stata-style missing-value tokens (`.a` through `.z`) are
  accepted in the map and labels arguments. Inert when no Stata-style
  missing-value tokens appear in either argument.

  When `NULL`, the convention is resolved from
  `joptions("missing.convention")`; if that is also unset, the default
  is SPSS. Most users set the convention once at the top of a session
  via
  [`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
  (or in their `.Rprofile`) rather than supplying this argument on every
  call. See
  [`?joptions`](https://jma61.github.io/jstats/reference/joptions.md)
  for details.

## Value

A `haven_labelled` vector with the recoded values, variable label, and
(if supplied or auto-transferred) value labels applied. Assign this to a
new column in your data frame:
`MyData$AgeGroupR <- jrecode(MyData, AgeGroup, map = "...")`

## Details

The function accepts haven-labelled, plain numeric, and factor
variables.

The variable label from the original variable is carried across
automatically with "(recoded)" appended. If the original variable has no
variable label, the variable name is used instead.

Value labels are handled in three ways, in order of priority:

1.  If `labels` is supplied, those labels are used as-is.

2.  If `labels` is omitted and the original variable has value labels,
    they are automatically transferred to the new codes — provided the
    mapping is one-to-one (no collapsing). For example, recoding 1/2 to
    1/0 will carry "Yes" and "No" across to the new codes automatically.

3.  If categories are collapsed (multiple old values map to one new
    value), automatic transfer is not possible and a note is printed
    directing you to supply labels manually.

NA values in the original variable are always set to NA in the new
variable, regardless of the `else` setting.

Values that appear to be coded missing values (e.g. -99, -9, 999) from
SPSS or another package are automatically detected and set to NA, even
when `else=copy` is used. A note is printed when this occurs.

If the map does not include an `else` clause and there are unmapped
values in the variable, the function stops with a message listing the
unmapped values so you can fix the map before proceeding.

If the map specifies values that do not exist in the original variable,
a warning is issued (but the function continues). This helps catch typos
in the map string.

**Missing values in the map.** The package supports two conventions for
representing user-defined missing values (UDMs), and the syntax for
producing UDMs from `jrecode()` depends on which one is active:

Under **SPSS convention** (the default), UDMs are real numeric codes
carrying metadata that flags them as missing. The two-step canonical
pattern is:


    df$EducR <- jrecode(df, Education,
                        map    = "1,2=1; 3=2; 4,5=3; -99,-98=-99",
                        labels = "1=High school or less; 2=Some college; 3=Degree")
    df <- jdeclare_udm(df, EducR, codes = c(Refused = -99))

The `jrecode()` call assigns the numeric sentinel `-99`; the subsequent
[`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md)
call attaches the label and flags `-99` as missing. Labeling `-99`
inside the `labels` argument is unnecessary —
[`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md)
owns that label.

Under **Stata convention**, UDMs are typed missing cells marked with
Stata-style tags (`.a` through `.z`). The single-call canonical pattern
is:


    df$EducR <- jrecode(df, Education,
                        map    = "1,2=1; 3=2; 4,5=3; else=.a",
                        labels = "1=High school or less; 2=Some college; 3=Degree; .a=Refused")

Under Stata convention,
[`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md)
is not needed for this pattern — `jrecode()` handles both the value
recoding and the Stata-style missing-value labeling in one call.

Writing Stata-style missing-value tokens while the active convention is
SPSS raises an informative error that echoes the user's call rewritten
in SPSS-style syntax. Switching the convention session-wide is one line:
`joptions(missing.convention = "stata")`.

## See also

[`jdeclare_udm`](https://jma61.github.io/jstats/reference/jdeclare_udm.md)
for declaring user-defined missing values on a column after a recode
(the SPSS-style canonical pattern).

[`jrelabel`](https://jma61.github.io/jstats/reference/jrelabel.md) for
applying labels to an existing variable after a recode.

[`joptions`](https://jma61.github.io/jstats/reference/joptions.md) for
the session-level `missing.convention` setting.

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Recode with explicit labels (a 1/2 dichotomy to 0/1)
df <- community
df$OwnsHome01 <- jrecode(df, OwnsHome,
                         map    = "1=1; 2=0",
                         labels = "0=No; 1=Yes")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Collapse categories (must supply labels)
df$RegionR <- jrecode(df, Region,
                      map    = "1,2=1; 3,4=2",
                      labels = "1=North or South; 2=East or West")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Use else=copy to carry unspecified values across unchanged
df$EducR <- jrecode(df, Education,
                    map    = "5=4; else=copy",
                    labels = "4=Bachelor's degree or higher")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Use else=NA to deliberately drop unspecified values to system NA
df$EducR2 <- jrecode(df, Education,
                     map    = "4=1; 5=1; else=NA",
                     labels = "1=College degree")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Convert a specific coded missing value to system NA
df$EducR3 <- jrecode(df, Education, map = "-99=System; else=copy")
#> Note: -98 ("Don't know") is a declared missing value and was kept on the recoded variable.
#> To convert it to a plain NA instead, add -98=NA to the map.
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Stata convention: Stata-style missing-value tokens in map and labels
# (single call; convention = "stata" scopes the choice to this call only)
df$EducR4 <- jrecode(df, Education,
                     map    = "1,2=1; 3,4,5=2; else=.a",
                     labels = "1=No college; 2=College; .a=Refused",
                     convention = "stata")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.

# Using juse() default
juse(df)
#> Default data frame set to: df
df$RegionR2 <- jrecode(Region, map = "1,2=1; 3,4=2",
                       labels = "1=North or South; 2=East or West")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.
```
