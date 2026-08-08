# Apply variable and value labels to a variable

`jrelabel()` attaches a variable label and/or value labels to any
variable in a data frame. It is designed as a simple label applicator —
it does not recode values, convert types, or compare variables. Use it
to add labels after a recode, to fix missing labels, or to label any
variable that needs them.

A variable label (`var.label`) can be attached to a variable of any type
— the variable is returned unchanged apart from the new label, so dates
stay dates, factors stay factors, and text stays text. Value labels
(`labels`) can be applied to haven-labelled, plain numeric, and logical
variables; logical values are stored as 1 (TRUE) and 0 (FALSE). Factor,
character, and date/time variables cannot carry value labels, and
`jrelabel()` refuses the `labels` argument for these with a message
naming the fix.

`jrelabel()` never rebuilds the variable it is given. Existing value
labels, SPSS-style missing values (`na_values` / `na_range`),
Stata-style missing values, and the variable's class all pass through
untouched unless an argument you supply replaces them: new value labels
replace the full existing set (as `VALUE LABELS` does in SPSS), and a
new variable label replaces the old one. A replacement set clears any
labels attached to declared missing-value codes; the declaration itself
is unaffected, but re-supply its label alongside the new value labels to
keep it.

Both the `labels` and `var.label` arguments are optional. If neither is
supplied, the function returns the variable unchanged.

## Usage

``` r
jrelabel(data, var, labels = NULL, var.label = NULL)
```

## Arguments

- data:

  A data frame containing the variable.

- var:

  The variable to label (unquoted, e.g. `StatusR`).

- labels:

  Optional. A quoted string specifying value labels using the format
  `"code=Label Text"` with rules separated by semicolons. Accepted on
  haven-labelled, plain numeric, and logical variables only.

  Examples:

  - `"1=Yes; 0=No"`

  - `"1=Employed; 2=Unemployed; 3=Student; 4=Retired"`

- var.label:

  Optional. A quoted string to use as the variable label (the
  description shown by
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md),
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md), etc.).
  If omitted, any existing variable label is preserved. If the variable
  has no existing label, no variable label is set.

## Value

The variable with the requested labels applied. The variable keeps its
class: haven-labelled input stays haven-labelled with any declared
SPSS-style or Stata-style missing values intact; plain numeric and
logical input becomes `haven_labelled` when value labels are applied;
any other type is returned unchanged apart from the labels. Assign the
result back to a column in your data frame:
`MyData$VarName <- jrelabel(MyData, VarName, ...)`

## See also

[`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md) for
recoding values with optional labels in a single step.

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# Add value labels after a recode
df <- data.frame(Status = c(1, 2, 1, 2, 1, 2))
df$StatusR <- ifelse(df$Status == 1, 1, 0)
df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No",
                       var.label = "Status (recoded)")

# Add just a variable label
df$StatusR <- jrelabel(df, StatusR, var.label = "Employment Status")

# Add just value labels
df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")

# Label a date variable (the variable stays a Date)
df$Enrolled <- as.Date(c("2024-01-15", "2024-02-01", "2024-01-20",
                         "2024-03-05", "2024-02-14", "2024-01-30"))
df$Enrolled <- jrelabel(df, Enrolled, var.label = "Enrollment date")

# Using juse() default
juse(df)
#> Default data frame set to: df
df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
```
