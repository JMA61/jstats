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

  The same aliases may also appear as an OLD value, converting plain
  `NA` cells to a code: `"NA=-98; else=copy"` recodes every `NA` to
  `-98` (declare the code afterward with
  [`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)).
  `NA` may be combined with numeric old values in one rule
  (`"NA,-99=-98"`) and may be named in at most one rule. Only plain `NA`
  cells are affected; tagged missing values are never converted by an
  `NA` rule. Under Stata or SAS convention the target may itself be a
  token: `"NA=.a"`.

  Under Stata or SAS convention, values can be mapped to tagged
  missing-value tokens: `"-99=.a; -98=.b"`.

  The right-hand side may also be the word `missing` (case-insensitive):
  the value is converted to your working convention's own missing form –
  a tagged marker under the Stata or SAS convention, or the first code
  from `joptions("missing.convention.codes")` under the SPSS convention,
  declared on the result automatically. The same map string therefore
  works under every setting: `"8=missing; else=copy"`. The NA rule
  composes with it (`"NA=missing"` converts plain `NA` cells the same
  way), and `labels = "missing=Refused"` labels whatever the token
  produced. If the column already carries the other convention's markers
  while your `missing.convention` setting is set, the call stops and
  shows both resolutions rather than guessing.

  Examples:

  - `"1=1; 2=0"`

  - `"1=1; 2,3=2; 4,5=3; else=NA"`

  - `"1=1; 2=0; else=copy"`

  - `"-5=System; else=copy"`

  - `"NA=-98; else=copy"`

  - `"3=1; 4=2; else=.a"` (Stata or SAS convention only)

  - `"8=missing; else=copy"` (any convention)

- labels:

  Optional. A quoted string specifying value labels for the new
  variable, using the format `"code=Label Text"` with rules separated by
  semicolons. If supplied, these labels are used as-is.

  The left side of each rule may be a numeric code or, under Stata
  convention, a Stata-style missing-value token (`.a` through `.z`).
  Tagged-NA labels are stored on the tag itself, not on a numeric code.
  It may also be the word `missing`, labelling whatever the map's
  `missing` target produced: `labels = "missing=Refused"`.

  If omitted, the function attempts to transfer value labels
  automatically from the original variable. This works when the original
  variable has value labels and the mapping is one-to-one (no categories
  are collapsed). When categories are collapsed, labels cannot be
  transferred automatically and a note is printed.

  Example: `"1=Male; 0=Female"` or `".a=Refused; .b=Don't know"`.

- convention:

  Optional. One of `"spss"`, `"stata"`, `"sas"`, or `NULL` (default);
  any capitalization is accepted. Controls whether missing-value tokens
  (`.a` through `.z` or `.A` through `.Z`) are accepted in the map and
  labels arguments. Token letters are matched case-insensitively; the
  stored markers take the convention's letter case (lowercase
  Stata-style under `"stata"`, uppercase SAS-style under `"sas"`). Inert
  when no such tokens appear in either argument.

  When `NULL`, the convention is resolved from
  `joptions("missing.convention")`; if that is also unset, the call
  stops with a guided error asking you to choose – the package never
  infers a convention. Most users set the convention once at the top of
  a session via
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

The function accepts haven-labelled, plain numeric, and logical
variables. Factor, character, and date/time variables are refused with a
message naming the fix — recoding works with a variable's numeric
values, so convert these to numeric first.

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

NA values in the original variable are carried across as NA unless the
map names `NA` as an old value (for example `"NA=-98"`); the `else`
setting never converts NA. An `NA` rule affects plain `NA` cells only —
Stata-style missing values (tagged NAs) are declared missings and are
preserved with their tags regardless of the map.

Values that appear to be coded missing values (e.g. -99, -9, 999) from
SPSS or another package are automatically detected and set to NA, even
when `else=copy` is used. A note is printed when this occurs.

If the map does not include an `else` clause and there are unmapped
values in the variable, the function stops with a message listing the
unmapped values so you can fix the map before proceeding.

If the map specifies values that do not exist in the original variable,
a warning is issued (but the function continues). This helps catch typos
in the map string.

**Missing values in the map.** The package supports three conventions
for representing declared missing values, and the syntax for producing
them from `jrecode()` depends on which one is active. A convention
becomes active via `joptions(missing.convention = ...)` or this call's
`convention` argument; with neither set, a call that produces declared
missing values stops with a guided error asking you to choose.

Under **SPSS convention**, declared missing values are real numeric
codes carrying metadata that flags them as missing. The two-step
canonical pattern is:


    df$EducR <- jrecode(df, Education,
                        map    = "1,2=1; 3=2; 4,5=3; -99,-98=-99",
                        labels = "1=High school or less; 2=Some college; 3=Degree")
    jdeclare_missing(df, EducR, codes = c(Refused = -99), modify = TRUE)

The `jrecode()` call assigns the numeric code `-99`; the subsequent
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
call attaches the label and flags `-99` as missing. Labeling `-99`
inside the `labels` argument is unnecessary —
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
owns that label.

The same two-step pattern serves data whose missingness arrived as plain
`NA` (data born in R, or read from a CSV): `map = "NA=-98; else=copy"`
converts the NA cells to the numeric code, and
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
declares it.

Under **Stata convention**, declared missing values are typed missing
cells marked with Stata-style tags (`.a` through `.z`). The single-call
canonical pattern is:


    df$EducR <- jrecode(df, Education,
                        map    = "1,2=1; 3=2; 4,5=3; else=.a",
                        labels = "1=High school or less; 2=Some college; 3=Degree; .a=Refused")

Under Stata convention,
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
is not needed for this pattern — `jrecode()` handles both the value
recoding and the Stata-style missing-value labeling in one call.

**SAS convention** works the same way with SAS-style missing values
(`.A` through `.Z`). Map and labels tokens are matched
case-insensitively, and the stored markers take the active convention's
letter case: lowercase under Stata convention, uppercase under SAS
convention.

Writing these missing-value tokens while the active convention is SPSS
raises an error naming the mismatch and the two ways out: restate the
markers as numeric codes to stay in SPSS convention, or switch
convention with `joptions(missing.convention = ...)` (or with this
call's `convention` argument). The error does not rewrite the call for
you: the SPSS-style codes would have to be taken from
`joptions("missing.convention.codes")`, which cannot be known to be free
of collision with values already in the column. The two-call SPSS-style
pattern is documented above.

## See also

[`jdeclare_missing`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
for declaring missing values on a column after a recode (the SPSS-style
canonical pattern).

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
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Collapse categories (must supply labels)
df$RegionR <- jrecode(df, Region,
                      map    = "1,2=1; 3,4=2",
                      labels = "1=North or South; 2=East or West")
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Use else=copy to carry unspecified values across unchanged
df$EducR <- jrecode(df, Education,
                    map    = "5=4; else=copy",
                    labels = "4=Bachelor's degree or higher")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were
#> kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Use else=NA to deliberately drop unspecified values to system NA
df$EducR2 <- jrecode(df, Education,
                     map    = "4=1; 5=1; else=NA",
                     labels = "1=College degree")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were
#> kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Convert a specific coded missing value to system NA
df$EducR3 <- jrecode(df, Education, map = "-99=System; else=copy")
#> Note: -98 ("Don't know") is a declared missing value and was kept on the
#> recoded variable.
#> To convert it to a plain NA instead, add -98=NA to the map.
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Give plain NA cells a codable value, then declare it. Declaring on a
# plain column needs a chosen missing-value convention (the package
# never infers one), so choose it first:
joptions(missing.convention = "spss")
#> Options Settings
#> Missing-value convention: SPSS-style
#> SPSS-style missing value codes: -99, -98, -97
#> Run joptions() to see all settings.
#> 
df$AgeR <- jrecode(df, Age, map = "NA=-98; else=copy")
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.
df <- jdeclare_missing(df, AgeR, codes = c("Not recorded" = -98))
#> Declared SPSS-style missing values on AgeR:
#>   -98 ["Not recorded"]
#> 
#> This call changes df only if you assign the result:
#>   df <- jdeclare_missing(df, AgeR, ...)
#> 
#> To change df directly, rerun with modify = TRUE:
#>   jdeclare_missing(df, AgeR, ..., modify = TRUE)

# Stata convention: Stata-style missing-value tokens in map and labels
# (single call; convention = "stata" scopes the choice to this call only)
df$EducR4 <- jrecode(df, Education,
                     map    = "1,2=1; 3,4,5=2; else=.a",
                     labels = "1=No college; 2=College; .a=Refused",
                     convention = "stata")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were
#> kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# SAS convention: the same single-call pattern; tokens are matched
# case-insensitively and the markers store in uppercase (.A)
df$EducR5 <- jrecode(df, Education,
                     map    = "1,2=1; 3,4,5=2; else=.a",
                     labels = "1=No college; 2=College; .a=Refused",
                     convention = "sas")
#> Note: -99 ("Refused"), -98 ("Don't know") are declared missing values and were
#> kept on the recoded variable.
#> To convert them to plain NA instead, map them to NA (for example -99=NA).
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.

# Using juse() default
juse(df)
#> Default data frame set to: df
df$RegionR2 <- jrecode(Region, map = "1,2=1; 3,4=2",
                       labels = "1=North or South; 2=East or West")
#> 
#> Note: This call changes df only if you assign the result:
#>   df$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.
```
