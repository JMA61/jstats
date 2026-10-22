# Apply variable and value labels to a variable

`jrelabel()` attaches a variable label and/or value labels to any
variable in a data frame. It is designed as a simple label applicator —
it does not recode values, convert types, or compare variables. Use it
to add labels after a recode, to fix missing labels, or to label any
variable that needs them.

It has two forms. The one-variable form,
`jrelabel(MyData, Q1, labels = ...)`, returns the labeled variable for
you to assign to a column, or with `modify = TRUE` labels the variable
in the data frame directly. The list form,
`jrelabel(MyData, c(Q1, Q2, Q3), labels = ..., modify = TRUE)`, gives
several variables the same value labels in one call – the way a set of
survey items sharing one response scale is labeled – and always changes
the data frame itself, so it takes `modify = TRUE`.

A variable label (`var.label`) can be attached to a variable of any type
— the variable is returned unchanged apart from the new label, so dates
stay dates, factors stay factors, and text stays text. Value labels
(`labels`) can be applied to haven-labelled, plain numeric, and logical
variables; logical values are stored as 1 (TRUE) and 0 (FALSE). Factor,
character, and date/time variables cannot carry value labels, and
`jrelabel()` refuses the `labels` argument for these; for factor and
text variables the message names
[`jencode`](https://jma61.github.io/jstats/reference/jencode.md) as the
fix.

`jrelabel()` never rebuilds the variable it is given. Existing value
labels, SPSS-style missing values (`na_values` / `na_range`),
Stata-style missing values, and the variable's class all pass through
untouched unless an argument you supply replaces them: new value labels
replace the existing ones (as `VALUE LABELS` does in SPSS), except that
a declared missing value keeps its label unless the new set names it, as
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)'s
`labels` argument keeps them, and a note names the labels kept; a new
variable label replaces the old one. To change a declared value's label,
name it in the new set, e.g. `labels = "1=Low; 2=High; -99=No answer"`.
On a column with Stata-style or SAS-style missing values, a marker that
no case carries is declared only by its label, and it stays declared;
name it by its marker to relabel it, e.g.
`labels = "1=Low; .c=Refused"`.

Both the `labels` and `var.label` arguments are optional in the
one-variable form. If neither is supplied, the function returns the
variable unchanged.

## Usage

``` r
jrelabel(
  data,
  var,
  labels = NULL,
  var.label = NULL,
  vars = NULL,
  modify = FALSE,
  ...
)
```

## Arguments

- data:

  A data frame containing the variable.

- var:

  The variable to label (unquoted, e.g. `StatusR`; a quoted name is
  accepted), or a [`c()`](https://rdrr.io/r/base/c.html) of two or more
  for the list form (see the section below).

- labels:

  Optional. A quoted string specifying value labels using the format
  `"code=Label Text"` with rules separated by semicolons. Accepted on
  haven-labelled, plain numeric, and logical variables only. A label may
  be written in quotes, with either mark, right after its equals sign,
  and a semicolon inside the quotes is then part of the label:
  `"1=Yes; 9=\"Refused; not asked\""`. An unquoted label reads as it is
  written.

  Examples:

  - `"1=Yes; 0=No"`

  - `"1=Employed; 2=Unemployed; 3=Student; 4=Retired"`

- var.label:

  Optional. A quoted string to use as the variable label (the
  description shown by
  [`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md),
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md), etc.).
  If omitted, any existing variable label is preserved. If the variable
  has no existing label, no variable label is set. One-variable form
  only.

- vars:

  Optional. For the list form: the variables' names in quotes, a stored
  or computed list such as `vars = items` or `vars = c("Q1", "Q2")`.
  Names typed without quotes go after the data frame, in a
  [`c()`](https://rdrr.io/r/base/c.html).

- modify:

  Logical. `TRUE` labels the variable(s) in the data frame directly, so
  no assignment is needed; the data frame must be given by its name (or
  set with
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md)).
  Optional in the one-variable form, which still returns the variable;
  required in the list form. Default `FALSE`.

- ...:

  Not used. An input `jrelabel()` does not take – a misspelled argument
  – stops with "unused input" and the name as typed, in place of R's own
  "unused argument".

## Value

The one-variable form: the variable with the requested labels applied,
returned invisibly (nothing prints at the console), with or without
`modify = TRUE`. The variable keeps its class: haven-labelled input
stays haven-labelled with any declared SPSS-style or Stata-style missing
values intact; plain numeric and logical input becomes `haven_labelled`
when value labels are applied; any other type is returned unchanged
apart from the labels. Without `modify = TRUE`, assign the result to a
column to keep it (at the standard and full output levels a note says so
after each call). Two assignment forms do that job:

- Preserving: `MyData$VarNameL <- jrelabel(MyData, VarName, ...)` adds a
  labeled copy and keeps the original as it was.

- Overwrite (the usual choice here):
  `MyData$VarName <- jrelabel(MyData, VarName, ...)` labels the variable
  in place. Labels change how values are shown, not the values, so there
  is normally nothing to keep a copy of.

SPSS users will recognize the pair from `RECODE ... INTO new.` and bare
`RECODE`; for labels, SPSS's `VALUE LABELS` and `VARIABLE LABELS` always
label in place, the overwrite form – which `modify = TRUE` gives
directly.

The list form: the changed data frame, invisibly.

## The list form

A [`c()`](https://rdrr.io/r/base/c.html) of two or more variables after
the data frame – or a stored list of names in quotes, `vars = items` –
applies the same value labels to each variable, in the data frame
itself:


    jrelabel(MyData, c(Q1, Q2, Q3),
             labels = "1=Never; 2=Sometimes; 3=Often", modify = TRUE)

The SPSS equivalent is
`VALUE LABELS Q1 Q2 Q3 1 'Never' 2 'Sometimes' 3 'Often'.` The form
takes `modify = TRUE` and stops without it, offering the call with it
added: a call that changes several variables returns the whole data
frame, and assigning that to one column (`MyData$Q1 <- jrelabel(...)`)
would put the data frame inside the column. It also returns the changed
data frame, so `e <- jrelabel(d, c(Q1, Q2), ..., modify = TRUE)` labels
`d` and keeps a copy in `e`. Every variable is checked before any is
changed, so a call that stops changes nothing. A variable label names
one variable and is refused in this form; give each its own call. A list
in `vars =` follows these rules whatever its length, so a script that
builds its list of names behaves the same when the list holds one name;
`c(Q1)` after the data frame is the one-variable form.

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
#> Note: This call changes df only if you assign the result:
#>   df$StatusR <- jrelabel(...)
#> 
#> To label StatusR in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)

# The same, labeling the variable in the data frame directly
jrelabel(df, StatusR, labels = "1=Yes; 0=No", modify = TRUE)
#> Value labels applied to StatusR in df.

# The data frame may also be given by name
df$StatusR <- jrelabel(data = df, StatusR, labels = "1=Yes; 0=No")
#> Note: This call changes df only if you assign the result:
#>   df$StatusR <- jrelabel(...)
#> 
#> To label StatusR in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)

# Add just a variable label
df$StatusR <- jrelabel(df, StatusR, var.label = "Employment Status")
#> Note: This call changes df only if you assign the result:
#>   df$StatusR <- jrelabel(...)
#> 
#> To label StatusR in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)

# Add just value labels
df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")
#> Note: This call changes df only if you assign the result:
#>   df$StatusR <- jrelabel(...)
#> 
#> To label StatusR in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)

# Label a date variable (the variable stays a Date)
df$Enrolled <- as.Date(c("2024-01-15", "2024-02-01", "2024-01-20",
                         "2024-03-05", "2024-02-14", "2024-01-30"))
df$Enrolled <- jrelabel(df, Enrolled, var.label = "Enrollment date")
#> Note: This call changes df only if you assign the result:
#>   df$Enrolled <- jrelabel(...)
#> 
#> To label Enrolled in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)

# Several items that share one response scale: the list form
sv <- data.frame(Q1 = c(1, 3, 2), Q2 = c(2, 2, 3), Q3 = c(3, 1, 1))
jrelabel(sv, c(Q1, Q2, Q3), labels = "1=Never; 2=Sometimes; 3=Often",
         modify = TRUE)
#> Value labels applied to Q1, Q2, and Q3 in sv.

# The same from a stored list of names
items <- c("Q1", "Q2", "Q3")
jrelabel(sv, vars = items, labels = "1=Never; 2=Sometimes; 3=Often",
         modify = TRUE)
#> Value labels applied to Q1, Q2, and Q3 in sv.

# Using juse() default
juse(df)
#> Default data frame set to: df
df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
#> Note: This call changes df only if you assign the result:
#>   df$StatusR <- jrelabel(...)
#> 
#> To label StatusR in df directly, rerun with modify = TRUE:
#>   jrelabel(..., modify = TRUE)
juse(NULL)
#> Default data frame cleared.
```
