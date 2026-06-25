# Declare user-defined missing values on a variable

`jdeclare_udm()` declares one or more user-defined missing values (UDMs)
on a variable. UDMs are specific data values – typically negative codes
such as `-99` or Stata-style tagged markers such as `.a` – that indicate
*why* a value is missing (refused, don't know, not applicable, etc.)
rather than simply that it is missing. Once declared, UDM cells are
automatically excluded from analyses but remain visible in the data for
diagnostic purposes (see
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)).

The function operates in declarative mode: each call states the column's
complete UDM set. A second call to `jdeclare_udm()` on the same column
replaces, not augments, the prior declaration. This matches SPSS's
`MISSING VALUES` and Stata's `mvdecode` semantics. When prior UDMs are
dropped, a note lists them so the destructive aspect of the replacement
is not silent.

## Usage

``` r
jdeclare_udm(
  data,
  var,
  codes = NULL,
  labels = NULL,
  convention = NULL,
  udm.notice = TRUE
)
```

## Arguments

- data:

  A data frame containing the variable.

- var:

  The variable to declare UDMs on (unquoted, e.g. `Income`).

- codes:

  Numeric vector of code values to declare as UDMs. Accepts two forms:

  Option A (separate codes and labels)

  :   Unnamed numeric vector; labels supplied via the `labels` argument.
      E.g.
      `codes = c(-99, -98), labels = "-99=Refused; -98=Don't know"`.

  Option C (haven-style named vector)

  :   Named numeric vector; names are the labels. E.g.
      `` codes = c(Refused = -99, `Don't know` = -98) ``.

  Under Stata convention, code values may be Stata-style missing-value
  markers created with
  [`haven::tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html),
  e.g. `codes = c(Refused = tagged_na("a"))`.

- labels:

  Optional. A quoted string in the form `"value=label; value=label"`
  pairing labels with codes (Option A only). Must be `NULL` when `codes`
  is named (Option C).

- convention:

  Optional. One of `"spss"` or `"stata"`; overrides the convention
  resolution for this call. When `NULL` (the default), the convention is
  resolved from the column's existing UDM declaration (if any), then
  from `joptions("missing.convention")`, then from the SPSS-form
  default.

- udm.notice:

  Logical. When `TRUE` (the default), the function prints a notification
  summarizing what was declared. Set `FALSE` to suppress.

## Value

The data frame, with the specified variable updated to carry the
declared UDMs.

## Missing-Values Convention

Under SPSS convention, codes are declared as numeric values via the
column's `na_values` attribute (haven's representation of SPSS-form
UDMs). The data cells themselves are unchanged; only the metadata that
flags certain values as missing is added.

Under Stata convention with Stata-style missing-value input, the
function attaches value labels to existing Stata-style missing-value
cells on the column.

Under Stata convention with numeric input, the function converts
matching cells to Stata-style missing-value markers (Session 30 design
lock). The mapping is ordering-based: codes sorted by absolute value
descending, more-negative-first as tie-breaker, then assigned `.a`,
`.b`, `.c`, `.d` in that order. The assignment proceeds independently of
`joptions("udm.convention.codes")` (which only governs the reverse
Stata-to-SPSS direction). A conversion note in the standard/full
`joutput` tier shows the Stata-style equivalent for future calls.

## Mixed conventions and file export

A single data frame may carry both SPSS-form and Stata-form UDM columns.
In-memory analysis and display tolerate the mix without issue (each
column renders in its native form). The constraint shows up at
file-export time: `.sav` cannot represent Stata-style missing values;
`.dta` cannot represent SPSS-form `na_values` declarations; `.xpt` can
represent neither form.
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md)
pre-flights the DF against the destination format and errors with a
pointer to
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
when the mix is incompatible. The post-declaration mismatch notice
emitted at the bottom of this function's output exists to alert you
early if a single-column declaration ends up out of step with the rest
of its DF.

## See also

[`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md),
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md),
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md),
[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)

## Examples

``` r
# clinic$MoodRating arrives "dirty": -99/-98 sit in the data as
# ordinary numbers (the state after a CSV or Excel import), so summary
# statistics are poisoned until the codes are declared missing.
df <- clinic
jdesc(df, MoodRating)        # mean dragged far down by -99/-98
#> Descriptive Statistics
#> 
#> Variable    Total  Non_missing  Min  Max    Mean      SD
#> ----------  -----  -----------  ---  ---  ------  ------
#> MoodRating     70           70  -99    9  -4.943  31.477
#> 

# SPSS form: declare -99 and -98 as UDMs with labels
df <- jdeclare_udm(df, MoodRating,
                   codes  = c(-99, -98),
                   labels = "-99=Refused; -98=Don't know")
#> Declared SPSS-style missing values in:
#>   df$MoodRating
#>   -99 ["Refused"]
#>   -98 ["Don't know"]
#> 
#> Assign the result to keep the declaration:
#>   df <- jdeclare_udm(df, MoodRating, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(df, "df.rds")
jdesc(df, MoodRating)        # codes now excluded as missing
#> Descriptive Statistics
#> 
#> Case Processing  Excluded  Remaining
#>     Original            —         70
#>     Remaining N         —         70
#> 
#> ────────────────────────────────────
#> 
#> 
#> Variable    Total  Non_missing  Min  Max  Mean     SD
#> ----------  -----  -----------  ---  ---  ----  -----
#> MoodRating     70           63    1    9  5.46  1.702
#> 

# Equivalent using named codes (one step instead of codes + labels)
df2 <- jdeclare_udm(clinic, MoodRating,
                    codes = c("Refused" = -99, "Don't know" = -98))
#> Declared SPSS-style missing values in:
#>   clinic$MoodRating
#>   -99 ["Refused"]
#>   -98 ["Don't know"]
#> 
#> Assign the result to keep the declaration:
#>   clinic <- jdeclare_udm(clinic, MoodRating, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(clinic, "clinic.rds")

# Stata-style: label Stata-style missing-value cells. The jrecode() call
# turns the literal codes into tagged cells; jdeclare_udm() labels them.
df3 <- clinic
df3$Mood2 <- jrecode(df3, MoodRating,
                     map = "-99=.a; -98=.b; else=copy",
                     convention = "stata")
#> 
#> Note: jrecode() returns the recoded values; assign them to a column to keep them:
#>   df3$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the new column.
df3 <- jdeclare_udm(df3, Mood2,
                    codes = c("Refused"    = haven::tagged_na("a"),
                              "Don't know" = haven::tagged_na("b")))
#> Labelled Stata-style missing values in:
#>   df3$Mood2
#>   .a ["Refused"]
#>   .b ["Don't know"]
#> 
#> Assign the result to keep the declaration:
#>   df3 <- jdeclare_udm(df3, Mood2, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(df3, "df3.rds")
#> Note: variable Mood2 is Stata-style, but other columns in df3 are predominantly SPSS-style.
#> Use jconvert() to align if desired.
```
