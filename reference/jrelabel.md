# Apply variable and value labels to a variable

`jrelabel()` attaches a variable label and/or value labels to any
variable in a data frame. It is designed as a simple label applicator —
it does not recode values or compare variables. Use it to add labels
after a recode, to fix missing labels, or to label any variable that
needs them.

The function accepts haven-labelled, plain numeric, factor, and
character variables. The output is always a `haven_labelled` vector,
which is compatible with all jstats functions.

Both the `labels` and `var.label` arguments are optional. If neither is
supplied, the function returns the variable unchanged as a
`haven_labelled` vector.

If the variable already has labels, they are silently overwritten when
new labels are provided.

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
  `"code=Label Text"` with rules separated by semicolons.

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

A `haven_labelled` vector with the requested labels applied. Assign this
back to a column in your data frame:
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

# Using juse() default
juse(df)
#> Default data frame set to: df
df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
```
