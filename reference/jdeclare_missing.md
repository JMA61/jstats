# Declare user-defined missing values on one or more variables

`jdeclare_missing()` declares one or more user-defined missing values
(UDMs) on one or more variables. UDMs are specific data values –
typically negative codes such as `-99` or Stata-style tagged markers
such as `.a` – that indicate *why* a value is missing (refused, don't
know, not applicable, etc.) rather than simply that it is missing. Once
declared, UDM cells are automatically excluded from analyses but remain
visible in the data for diagnostic purposes (see
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)).

The function operates in declarative mode: what a call mentions, it
replaces; what it omits survives. Supplying `codes` replaces the
column's discrete-code set; supplying `range` replaces the column's
missing-value range; an existing range survives a codes-only call, and
existing discrete codes survive a range-only call. A second call
therefore replaces, not augments, whichever parts it names – matching
SPSS's `MISSING VALUES` and Stata's `mvdecode` semantics, neither of
which has an additive form. When prior UDMs are dropped, a note lists
them so the destructive aspect of the replacement is not silent.

Variables are given either as unquoted names
(`jdeclare_missing(df, MathScore, EnglishScore, codes = c(-99))`) or as
a character vector via `vars =` (the programmatic form, e.g.
`vars = offence_cols`). A multi-variable call applies the same
declaration to every named column, all-or-nothing: if any column fails a
check, no column is changed. There is deliberately no whole-data-frame
default – declaring a code frame-wide would flag it missing even on
columns where that value is legitimate data. To declare on every column,
pass `vars = names(data)` explicitly.

## Usage

``` r
jdeclare_missing(
  data,
  ...,
  codes = NULL,
  labels = NULL,
  range = NULL,
  vars = NULL,
  convention = NULL,
  missing.notice = TRUE,
  modify = FALSE
)
```

## Arguments

- data:

  A data frame containing the variable(s).

- ...:

  The variable(s) to declare UDMs on, as unquoted names (e.g. `Income`,
  or `MathScore, EnglishScore`). Use either `...` or `vars`, not both.
  All arguments after the variables must be named.

- codes:

  Numeric vector of code values to declare as UDMs. Accepts two forms:

  Option A (separate codes and labels)

  :   Unnamed numeric vector; labels supplied via the `labels` argument.
      E.g.
      `codes = c(-99, -98), labels = "-99=Refused; -98=Don't know"`.

  Option C (haven-style named vector)

  :   Named numeric vector; names are the labels. E.g.
      `` codes = c(Refused = -99, `Don't know` = -98) ``.

  On a column that already carries Stata-style or SAS-style missing
  values, codes may name the markers directly as quoted tokens, e.g.
  `codes = c(Refused = ".a")` – a token `".a"` means the `.a` marker (or
  `.A` on a SAS-style column: token case is accepted either way and
  canonicalized to the column's convention). Tokens are refused on
  columns with no tagged missing values to label (see the Missing-Values
  Convention section).

  A token may name a marker that no case currently carries – useful for
  FORWARD-DECLARING a label before recoding values into it. The label
  attaches, nothing in the data changes, and the notification says the
  marker is not present in the data. Such a label survives both a Stata
  and an SPSS round trip.

  A token given with no label is a no-op on an already-tagged column:
  the cells are already missing, so the only act available is naming a
  marker, and the call reports that it changed nothing. This differs
  from the numeric form, where a bare code IS the declaration.

- labels:

  Optional. A quoted string in the form `"value=label; value=label"`
  pairing labels with codes (Option A only). Must be `NULL` when `codes`
  is named (Option C). When a `range` is in effect (supplied in this
  call, or already on the column), entries may also name values inside
  the range: those attach as value labels on the in-range values without
  becoming discrete declared codes (see the Missing-value ranges
  section).

- range:

  Optional. A length-2 numeric vector declaring a missing-value RANGE
  (band), e.g. `range = c(-99, -51)` – every value from the first bound
  through the second is treated as missing. The SPSS parallel is
  `MISSING VALUES X (-99 THRU -51)`. Bounds may be non-integer, and one
  bound may be infinite (`c(-Inf, -51)` is SPSS's `LO THRU -51`). A
  missing-value range can exist only under SPSS convention: combining
  `range` with the Stata or SAS convention – as a per-call argument or
  as the
  [`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
  setting – or with tagged tokens is refused, and the refusal teaches
  the two-step route (declare the range under SPSS convention, then
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
  the column) when the range covers few enough values to convert. When
  no convention is selected anywhere, a range declaration stops and asks
  for `convention = "spss"` on the call. SPSS allows at most ONE
  discrete code alongside a range, and the check applies to the column's
  composed result (what this call supplies plus what already survives on
  the column), so a declaration that a `.sav` file could not hold is
  refused here rather than at save time.

- vars:

  Optional. A character vector of variable names, the programmatic
  alternative to unquoted names in `...` (e.g.
  `vars = c("Age", "Income")`, or `vars = offence_cols` where
  `offence_cols` holds the names). Use either `vars` or `...`, not both.

- convention:

  Optional. One of `"spss"`, `"stata"`, or `"sas"` (any capitalization
  is accepted); overrides the convention resolution for this call. When
  `NULL` (the default), the convention is resolved from the column's
  existing UDM declaration (if any), then from
  `joptions("missing.convention")`; when neither supplies one, the call
  stops with a guided error asking you to choose – the package never
  infers a convention for a fresh declaration. A `range` requires SPSS
  convention (see `range`). The SAS convention behaves as the Stata
  convention with uppercase markers: markers are stored and labeled as
  `.A`-`.Z`. Token input is case-insensitive under both tagged
  conventions; the case written to the column follows the resolved
  convention.

- missing.notice:

  Logical. When `TRUE` (the default), the function prints a notification
  summarizing what was declared, plus a reminder of how to keep the
  result. Set `FALSE` to suppress.

- modify:

  Logical. When `TRUE`, the declaration is written back onto the data
  frame named in the call (or onto the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  when the data argument is omitted), so no assignment is needed – the
  recommended workflow, since a declaration lost to a forgotten
  assignment silently poisons later statistics. Requires the data frame
  to be given as a plain name. When `FALSE` (the default), the caller's
  data frame is untouched; assign the returned data frame to keep the
  declaration.

## Value

The data frame, with the specified variable(s) updated to carry the
declared UDMs, returned invisibly. With the default `modify = FALSE`,
the caller's data frame is unchanged until the result is assigned back.
With `modify = TRUE`, the change is also written back onto the caller's
data frame, and the returned copy can be ignored.

## Missing-Values Convention

Under SPSS convention, codes are declared as numeric values via the
column's `na_values` attribute (haven's representation of SPSS-form
UDMs). The data cells themselves are unchanged; only the metadata that
flags certain values as missing is added.

Under Stata or SAS convention with tagged missing-value input (quoted
tokens such as `".a"`), the function attaches value labels to the
column's existing tagged missing-value markers. This requires the column
to already carry tagged missing values – either tagged cells, or markers
previously declared through value labels (a marker may be labeled before
any cases carry it, so a declaration made early in data collection is
complete for later data). Token case is accepted either way and
canonicalized to the resolved convention: lowercase markers under Stata
convention, uppercase under SAS. Tokens against a column with no tagged
missing values are refused identically under every convention source: on
a plain column the error points at
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
(which creates tagged cells from numeric codes); on a column carrying
SPSS-style declarations it points at
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md).

Note that on a plain numeric column with plain numeric codes and no
`convention` argument, the resolved convention decides the outcome:
under SPSS convention the numbers stay in the cells and are flagged
missing; under Stata or SAS convention the matching cells are converted
to markers and the numbers leave the data. This is the one place
`joptions(missing.convention = ...)` changes what happens to data (see
the examples).

Under Stata or SAS convention with numeric input, the function converts
matching cells to tagged missing-value markers (Session 30 design lock;
SAS convention writes the same letters uppercase). The mapping is
ordering-based: codes sorted by absolute value descending,
more-negative-first as tie-breaker, then assigned `.a`, `.b`, `.c`, `.d`
in that order (`.A`, `.B`, ... under SAS convention). The assignment
proceeds independently of `joptions("missing.convention.codes")` (which
only governs the reverse Stata-to-SPSS direction). A conversion note in
the standard/full `joutput` tier shows the Stata-style equivalent for
future calls.

## Missing-value ranges

A range declares a whole band of values missing at once – the form
commercial statistical software uses when a study's missing-value codes
share a band (e.g. every code from -99 through -51). SPSS accepts at
most three discrete missing values, OR a range, OR a range plus one
discrete value; `jdeclare_missing()` enforces the same rule on the
composed result of each call, so a declaration is refused at the moment
it becomes illegal rather than when
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) later
refuses the file. A range-only call is complete in itself
(`jdeclare_missing(df, X, range = c(-99, -51))`).

Values inside the band may carry value labels: with a range in effect,
`labels` entries that match no discrete code but fall inside the band
attach as ordinary value labels on those values. They do not become
discrete declared codes – the band already covers them – but analysis
output that breaks out in-range values can then show their meanings.
Because a range replaces the column's existing range and existing
discrete codes survive a range-only call, a column already carrying two
or more discrete codes cannot take a range in the same declaration; the
call is refused with the surviving codes named.

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
early if a declaration ends up out of step with the rest of its DF.

## See also

[`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md),
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md),
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md),
[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)

## Examples

``` r
# A fresh declaration needs a chosen missing-value convention; the
# package never infers one. Choose SPSS convention for these examples:
joptions(missing.convention = "spss")
#> Options Settings
#> Missing-value convention: SPSS-style
#> SPSS-style missing value codes: -99, -98, -97
#> Run joptions() to see all settings.
#> 

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

# SPSS form: declare -99 and -98 as UDMs with labels. modify = TRUE
# writes the declaration back onto df in one step -- the recommended
# workflow.
jdeclare_missing(df, MoodRating,
             codes  = c(-99, -98),
             labels = "-99=Refused; -98=Don't know",
             modify = TRUE)
#> Declared SPSS-style missing values on MoodRating in df:
#>   -99 ["Refused"]
#>   -98 ["Don't know"]
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(df, "df.rds")
jdesc(df, MoodRating)        # codes now excluded as missing
#> Descriptive Statistics
#> 
#> Case Processing  Excluded  Remaining
#>     Original           --         70
#>     Remaining N        --         70
#> 
#> ------------------------------------
#> 
#> 
#> Variable    Total  Non_missing  Min  Max  Mean     SD
#> ----------  -----  -----------  ---  ---  ----  -----
#> MoodRating     70           63    1    9  5.46  1.702
#> 

# Equivalent without modify: assign the returned data frame back
df2 <- clinic
df2 <- jdeclare_missing(df2, MoodRating,
                    codes  = c(-99, -98),
                    labels = "-99=Refused; -98=Don't know")
#> Declared SPSS-style missing values on MoodRating:
#>   -99 ["Refused"]
#>   -98 ["Don't know"]
#> 
#> This call changes df2 only if you assign the result:
#>   df2 <- jdeclare_missing(df2, MoodRating, ...)
#> 
#> To change df2 directly, rerun with modify = TRUE:
#>   jdeclare_missing(df2, MoodRating, ..., modify = TRUE)

# Equivalent using named codes (one step instead of codes + labels)
df3 <- jdeclare_missing(clinic, MoodRating,
                    codes = c("Refused" = -99, "Don't know" = -98))
#> Declared SPSS-style missing values on MoodRating:
#>   -99 ["Refused"]
#>   -98 ["Don't know"]
#> 
#> This call changes clinic only if you assign the result:
#>   clinic <- jdeclare_missing(clinic, MoodRating, ...)
#> 
#> To change clinic directly, rerun with modify = TRUE:
#>   jdeclare_missing(clinic, MoodRating, ..., modify = TRUE)

# A missing-value RANGE: every value from -99 through -51 is missing.
# SPSS parallel: MISSING VALUES MoodRating (-99 THRU -51).
df4 <- jdeclare_missing(clinic, MoodRating, range = c(-99, -51))
#> Declared SPSS-style missing values on MoodRating:
#>   range -99 to -51
#> 
#> This call changes clinic only if you assign the result:
#>   clinic <- jdeclare_missing(clinic, MoodRating, ...)
#> 
#> To change clinic directly, rerun with modify = TRUE:
#>   jdeclare_missing(clinic, MoodRating, ..., modify = TRUE)

# Range plus labeled values inside the band, on several variables at
# once. The same declaration lands on every named column,
# all-or-nothing.
if (FALSE) { # \dontrun{
jdeclare_missing(mydata, vars = c("Theft", "Assault", "Burglary"),
             range  = c(-99, -51),
             labels = "-99=Refused; -61=Not applicable",
             modify = TRUE)
} # }

# Stata-style: label Stata-style missing-value cells. The jrecode() call
# turns the literal codes into tagged cells; jdeclare_missing() labels them
# by naming the markers as quoted tokens.
df5 <- clinic
df5$Mood2 <- jrecode(df5, MoodRating,
                     map = "-99=.a; -98=.b; else=copy",
                     convention = "stata")
#> 
#> Note: This call changes df5 only if you assign the result:
#>   df5$<name> <- jrecode(...)
#> To check the recode landed correctly, compare jfreq() on the original and the
#> new column.
jdeclare_missing(df5, Mood2,
             codes = c("Refused" = ".a", "Don't know" = ".b"),
             modify = TRUE)
#> Named Stata-style missing values on Mood2 in df5:
#>   .a is now "Refused"
#>   .b is now "Don't know"
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(df5, "df5.rds")
#> 
#> Note: Mood2 uses Stata-style missing values, but your missing.convention
#> setting is "spss".
#> To convert the data frame, run:
#>   jconvert(df5, to = "spss", modify = TRUE)
#> To keep Stata-style instead, change the setting:
#>   joptions(missing.convention = "stata")
#> Note: Mood2 uses Stata-style missing values, but other columns in df5
#> are SPSS-style.
#> Mixing forms is allowed. To align Mood2 with the rest, run:
#>   jconvert(df5, to = "spss", vars = "Mood2", modify = TRUE)

if (FALSE) { # \dontrun{
# The same neutral call -- plain numeric codes, no convention argument,
# plain column -- forks on joptions(missing.convention = ...):
joptions(missing.convention = "spss")
df6 <- jdeclare_missing(clinic, MoodRating, codes = c(-99))
# -99 stays in the cells, flagged as missing (SPSS-form declaration)

joptions(missing.convention = "stata")
df7 <- jdeclare_missing(clinic, MoodRating, codes = c(-99))
# -99 cells become the .a marker; the number -99 leaves the data
} # }
```
