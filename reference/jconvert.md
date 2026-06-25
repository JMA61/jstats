# Convert user-defined missing value (UDM) declarations between formats

`jconvert()` provides a single entry point for changing how user-
defined missing values (UDMs) are represented on the columns of a data
frame already in memory. Three target formats are supported: SPSS-style
(`na_values` on `haven_labelled_spss`), Stata-style (`tagged_na` on
`haven_labelled`), and base R (declarations stripped, declared cells
converted to plain `NA`). Replaces `jstrip_udm()` (retired in v0.9.5);
the base R target is the strip behavior.

## Usage

``` r
jconvert(data, to = NULL, ..., vars = NULL, udm.notice = TRUE)
```

## Arguments

- data:

  A data frame, or omitted to use the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.

- to:

  One of `"baseR"`, `"spss"`, or `"stata"` (case-sensitive). When `NULL`
  (the default), `jconvert()` reads `joptions("missing.convention")`: if
  the slot is set to `"spss"` or `"stata"`, `to` resolves to that value;
  if the slot is at its `"none"` default, `jconvert()` errors with
  guidance naming the three concrete options. The destructive `"baseR"`
  target is never auto-resolved – it must always be passed explicitly.

- ...:

  Optional unquoted variable names. When supplied, only the listed
  variables are scanned. Mutually exclusive with `vars`.

- vars:

  Alternative scope-by-vector path: a character vector of variable
  names. Mutually exclusive with `...`. When both `...` and `vars` are
  empty, `jconvert()` operates on the whole data frame.

- udm.notice:

  Logical; `TRUE` (default) prints a notification summarizing what was
  converted (and what was skipped) along with an assignment-syntax
  reminder. `FALSE` suppresses the message. Always-on by default; does
  not consult
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  because the function reports an action it just performed rather than
  explaining system behavior.

## Value

The data frame with the requested conversions applied, returned
invisibly. As with
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md) and
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md), the
user must assign the return value back to retain the changes.

## Details

The three target formats:

- `to = "baseR"`:

  Strip all UDM declarations and convert declared cells to plain `NA`.
  For SPSS-form columns (`na_values` / `na_range` on
  `haven_labelled_spss`), masks declared codes to `NA` and removes the
  attributes; value labels are preserved so the column can still
  round-trip through
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) with
  original labeling. For columns carrying Stata-style missing values
  (`tagged_na` markers), uses
  [`haven::zap_missing()`](https://haven.tidyverse.org/reference/zap_missing.html)
  to convert them to plain `NA`s.

- `to = "spss"`:

  Convert Stata-style or SAS-style missing values to SPSS-form numeric
  codes. Letter tags map to numeric codes via
  `joptions("udm.convention.codes")` (default `-99`, `-98`, `-97`):
  `.a -> codes[1]`, `.b -> codes[2]`, and so on. SAS-style (uppercase)
  tags are case-corrected to Stata-style (lowercase) before the numeric
  mapping – for round-trip purposes the package treats `.A` and `.a` as
  the same conceptual marker, and mixed-case columns collapse to a
  single lowercase marker (SPSS has no parallel uppercase convention).
  The notification's per-column display shows the original
  (pre-correction) tag for SAS-corrected columns – e.g.
  `.A "Refused" -> -99` – so the user-visible mapping reflects what was
  actually in the data on input. Letter tags beyond `.d` (after case
  correction) are refused with guidance to use
  [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md) for
  manual mapping.

- `to = "stata"`:

  Convert SPSS-form numeric codes to Stata-style missing values. Letter
  tags are assigned by ordering rather than by convention: each column's
  own declared `na_values` codes are sorted by absolute value descending
  (ties broken with more-negative-first), then mapped `.a, .b, .c` in
  that order. Convention codes are NOT consulted for this direction;
  they only govern the reverse (Stata to SPSS) mapping. Round-trip
  conversions are not guaranteed to preserve the original numeric codes
  (e.g. SPSS `c(-1, 9)` -\> Stata `.a, .b` -\> SPSS `c(-99, -98)` loses
  the original numbers), but the value labels survive intact and the
  missingness semantics are preserved. Range-based SPSS missings
  (`na_range`) are out of cross-format scope; columns with `na_range`
  are refused with guidance to enumerate the range in SPSS first.
  Columns with more than 4 distinct `na_values` codes are also refused
  (matches the 4-code cap on Stata letter-tag mapping).

Pre-flight checks for `to = "spss"` include a collision check: if a
column's target numeric code (e.g. `-99` for `.a`) is present as genuine
data in the column, the call errors before any data is touched. The
error message lists every colliding column and presents three resolution
paths: change the convention codes via
`joptions(udm.convention.codes = ...)`, scope the call via
`vars = c(...)` to exclude affected columns, or recode the real- data
values via
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
first. Atomicity applies to every error mode – the entire `jconvert()`
call either succeeds or errors before mutating the data frame.

**Pattern A – value labels suggest missingness but no formal
declaration.** When a column has no formal UDM declaration but carries
value labels matching the package's missing-label wordlist (e.g.
`"Refused"`, `"Don't know"`, `"Not applicable"`), `jconvert()` skips the
column and surfaces it in the notification with the affected value/label
pairs. To formalise these as UDMs use
[`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md);
to leave them as ordinary data, no action is needed.

## See also

[`jload`](https://jma61.github.io/jstats/reference/jload.md) for the
load-time strip alternative (`preserve.udm = FALSE`);
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md) for
setting the default convention and convention codes session-wide.

## Examples

``` r
# community ships with SPSS-form UDMs (Income, Education, Smoker,
# Environment1, Environment3), so the conversions run on it directly.

# Strip UDMs from every applicable variable:
df <- jconvert(community, to = "baseR")
#> Stripped declarations of user-defined missing values (UDMs) from 5 variables:
#>   Income        (-99 "Refused", -98 "Don't know")
#>   Education     (-99 "Refused", -98 "Don't know")
#>   Smoker        (-99 "Refused")
#>   Environment1  (-99 "Refused", -98 "Don't know")
#>   Environment3  (-99 "Refused", -98 "Don't know")
#> 
#> Assign the result to keep the conversion:
#>   community <- jconvert(community, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(community, "community.rds")

# Convert SPSS-form UDMs to Stata-style missing values:
df <- jconvert(community, to = "stata")
#> Converted to Stata-style missing values in 5 variables:
#>   Income        (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Education     (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Smoker        (-99 "Refused" -> .a)
#>   Environment1  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Environment3  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#> 
#> Assign the result to keep the conversion:
#>   community <- jconvert(community, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(community, "community.rds")

# Scope by unquoted names:
df <- jconvert(community, to = "baseR", Income, Education)
#> Stripped declarations of user-defined missing values (UDMs) from 2 variables:
#>   Income     (-99 "Refused", -98 "Don't know")
#>   Education  (-99 "Refused", -98 "Don't know")
#> 
#> Assign the result to keep the conversion:
#>   community <- jconvert(community, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(community, "community.rds")

# Scope by character vector (alternative form):
df <- jconvert(community, to = "baseR", vars = c("Income", "Education"))
#> Stripped declarations of user-defined missing values (UDMs) from 2 variables:
#>   Income     (-99 "Refused", -98 "Don't know")
#>   Education  (-99 "Refused", -98 "Don't know")
#> 
#> Assign the result to keep the conversion:
#>   community <- jconvert(community, ...)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(community, "community.rds")

# Suppress the notification (e.g. inside a script):
df <- jconvert(community, to = "baseR", udm.notice = FALSE)

if (FALSE) { # \dontrun{
# Convert with target inferred from joptions:
joptions(missing.convention = "spss")
df <- jconvert(df)   # converts any Stata-form columns to SPSS
} # }
```
