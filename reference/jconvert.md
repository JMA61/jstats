# Convert missing-value declarations between formats

`jconvert()` provides a single entry point for changing how declared
missing values are represented on the columns of a data frame already in
memory. Four target formats are supported: SPSS-style (`na_values` on
`haven_labelled_spss`), Stata-style (lowercase `tagged_na` on
`haven_labelled`), SAS-style (uppercase `tagged_na` on
`haven_labelled`), and base R (declarations stripped, declared cells
converted to plain `NA`). The haven package and its documentation call
these user-defined missing values.

## Usage

``` r
jconvert(
  data,
  to = NULL,
  ...,
  vars = NULL,
  missing.notice = TRUE,
  modify = FALSE
)
```

## Arguments

- data:

  A data frame, or omitted to use the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.

- to:

  One of `"baseR"`, `"spss"`, `"stata"`, or `"sas"` (any capitalization
  is accepted). When `NULL` (the default), `jconvert()` reads
  `joptions("missing.convention")`: if the slot is set to `"spss"`,
  `"stata"`, or `"sas"`, `to` resolves to that value; if the slot is at
  its `"none"` default, `jconvert()` errors with guidance naming the
  concrete options. The destructive `"baseR"` target is never
  auto-resolved – it must always be passed explicitly.

- ...:

  Optional unquoted variable names. When supplied, only the listed
  variables are scanned. Mutually exclusive with `vars`.

- vars:

  Alternative scope-by-vector path: a character vector of variable
  names. Mutually exclusive with `...`. When both `...` and `vars` are
  empty, `jconvert()` operates on the whole data frame.

- missing.notice:

  Logical; `TRUE` (default) prints a notification summarizing what was
  converted (and what was skipped) along with a reminder of how to keep
  the result. `FALSE` suppresses the message. Always-on by default; does
  not consult
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
  because the function reports an action it just performed rather than
  explaining system behavior.

- modify:

  Logical. When `TRUE`, the converted data frame is written back onto
  the data frame named in the call (or onto the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  when the data argument is omitted), so no assignment is needed – the
  recommended workflow, since conversions lost to a forgotten assignment
  silently change how later analyses treat the affected values. Requires
  the data frame to be given as a plain name. When `FALSE` (the
  default), the caller's data frame is untouched; assign the returned
  data frame to keep the conversions.

## Value

The data frame with the requested conversions applied, returned
invisibly. With the default `modify = FALSE`, the caller's data frame is
unchanged until the result is assigned back. With `modify = TRUE`, the
conversions are also written back onto the caller's data frame, and the
returned copy can be ignored.

## Details

The three target formats:

- `to = "baseR"`:

  Strip all missing-value declarations and convert declared cells to
  plain `NA`. For SPSS-style columns (`na_values` / `na_range` on
  `haven_labelled_spss`), masks declared codes to `NA` and removes the
  attributes; value labels are preserved so the column can still
  round-trip through
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) with
  original labeling. For columns carrying Stata-style missing values
  (`tagged_na` markers), uses
  [`haven::zap_missing()`](https://haven.tidyverse.org/reference/zap_missing.html)
  to convert them to plain `NA`s.

- `to = "spss"`:

  Convert Stata-style or SAS-style missing values to SPSS-style numeric
  codes. Letter tags map to numeric codes via
  `joptions("missing.convention.codes")` (default `-99`, `-98`, `-97`):
  `.a -> codes[1]`, `.b -> codes[2]`, and so on. SAS-style (uppercase)
  tags are case-corrected to Stata-style (lowercase) before the numeric
  mapping – for round-trip purposes the package treats `.A` and `.a` as
  the same conceptual marker, and mixed-case columns collapse to a
  single lowercase marker (SPSS has no parallel uppercase convention).
  The notification's per-column display shows the original
  (pre-correction) tag for SAS-corrected columns – e.g.
  `.A "Refused" -> -99` – so the user-visible mapping reflects what was
  actually in the data on input. Letter tags beyond those covered by the
  convention codes (default `.a`–`.c`, one letter per code, after case
  correction) are refused with guidance to use
  [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md) for
  manual mapping.

- `to = "stata"`:

  Convert SPSS-style numeric codes to Stata-style missing values. Letter
  tags are assigned by ordering rather than by convention: each column's
  own declared `na_values` codes are sorted by absolute value descending
  (ties broken with more-negative-first), then mapped `.a, .b, .c` in
  that order. Convention codes are NOT consulted for this direction;
  they only govern the reverse (Stata to SPSS) mapping. Round-trip
  conversions are not guaranteed to preserve the original numeric codes
  (e.g. SPSS `c(-1, 9)` -\> Stata `.a, .b` -\> SPSS `c(-99, -98)` loses
  the original numbers), but the value labels survive intact and the
  missingness semantics are preserved. Range-based SPSS missings
  (`na_range`) are enumerated: Stata-style missing values have no range
  concept, so the distinct range values present in the column's data,
  plus any range values carrying a value label, are translated
  individually. They join the column's discrete `na_values` codes in a
  single set, sorted and lettered by the same ordering rule. The range
  rule itself is not preserved – a range value with neither a data
  occurrence nor a label at conversion time is not translated, so if it
  first appears in later data it arrives as an ordinary data value. A
  column whose combined set exceeds 26 values (the `.a`–`.z` alphabet)
  is refused before any data is touched. A range declaration with no
  values to translate does not block the conversion: the column still
  converts, with the empty range declaration dropped and reported.
  SAS-style (uppercase) tagged columns are case-corrected to Stata-style
  (lowercase) and counted as converted; columns already fully lowercase
  are skipped as already in the target form.

- `to = "sas"`:

  Identical to `to = "stata"` except that the letters are uppercase
  (`.A`–`.Z`, SAS's native extended-missing convention): SPSS-style
  columns are enumerated and mapped to uppercase tags, Stata-style
  (lowercase) tagged columns are case-corrected to uppercase and counted
  as converted, and columns already fully uppercase are skipped. Inside
  R the two tagged forms are the same structure differing only in letter
  case; note that saving to Stata format (.dta) lowercases uppercase
  tags again, since the .dta format only supports lowercase letters.

Pre-flight checks for `to = "spss"` include a collision check: if a
column's target numeric code (e.g. `-99` for `.a`) is present as genuine
data in the column, the call errors before any data is touched. The
error message lists every colliding column and presents three resolution
paths: change the convention codes via
`joptions(missing.convention.codes = ...)`, scope the call via
`vars = c(...)` to exclude affected columns, or recode the real- data
values via
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
first. Atomicity applies to every error mode – the entire `jconvert()`
call either succeeds or errors before mutating the data frame.

**Pattern A – value labels suggest missingness but no formal
declaration.** When a column has no formal missing-value declaration but
carries value labels matching the package's missing-label wordlist (e.g.
`"Refused"`, `"Don't know"`, `"Not applicable"`), `jconvert()` skips the
column and surfaces it in the notification with the affected value/label
pairs. To formalize these as declared missing values use
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md);
to leave them as ordinary data, no action is needed.

## See also

[`jload`](https://jma61.github.io/jstats/reference/jload.md) for the
load-time strip alternative (`preserve.declarations = FALSE`);
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md) for
setting the default convention and convention codes session-wide.

## Examples

``` r
# community ships with SPSS-style missing values (Income, Education,
# Smoker, Environment1, Environment3), so the conversions run on it
# directly.

# Convert SPSS-style to Stata-style missing values. modify = TRUE
# writes the result back onto df in one step -- the recommended
# workflow.
df <- community
jconvert(df, to = "stata", modify = TRUE)
#> Converted to Stata-style missing values in 5 variables:
#>   Income        (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Education     (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Smoker        (-99 "Refused" -> .a)
#>   Environment1  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Environment3  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#> 
#> To keep it across sessions, save the data frame:
#>   jsave(df, "df.rds")

# Equivalent without modify: assign the returned data frame back
df2 <- jconvert(community, to = "stata")
#> Converted to Stata-style missing values in 5 variables:
#>   Income        (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Education     (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Smoker        (-99 "Refused" -> .a)
#>   Environment1  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#>   Environment3  (-99 "Refused" -> .a, -98 "Don't know" -> .b)
#> 
#> This call changes community only if you assign the result:
#>   community <- jconvert(community, ...)
#> 
#> To change community directly, rerun with modify = TRUE:
#>   jconvert(community, ..., modify = TRUE)

# Convert to SAS-style missing values (uppercase .A, .B, ...):
df_sas <- jconvert(community, to = "sas")
#> Converted to SAS-style missing values in 5 variables:
#>   Income        (-99 "Refused" -> .A, -98 "Don't know" -> .B)
#>   Education     (-99 "Refused" -> .A, -98 "Don't know" -> .B)
#>   Smoker        (-99 "Refused" -> .A)
#>   Environment1  (-99 "Refused" -> .A, -98 "Don't know" -> .B)
#>   Environment3  (-99 "Refused" -> .A, -98 "Don't know" -> .B)
#> 
#> This call changes community only if you assign the result:
#>   community <- jconvert(community, ...)
#> 
#> To change community directly, rerun with modify = TRUE:
#>   jconvert(community, ..., modify = TRUE)

# Strip the declarations from every applicable variable:
df3 <- jconvert(community, to = "baseR")
#> Stripped the missing-value declarations from 5 variables:
#>   Income        (-99 "Refused", -98 "Don't know")
#>   Education     (-99 "Refused", -98 "Don't know")
#>   Smoker        (-99 "Refused")
#>   Environment1  (-99 "Refused", -98 "Don't know")
#>   Environment3  (-99 "Refused", -98 "Don't know")
#> 
#> This call changes community only if you assign the result:
#>   community <- jconvert(community, ...)
#> 
#> To change community directly, rerun with modify = TRUE:
#>   jconvert(community, ..., modify = TRUE)

# Scope by unquoted names:
df4 <- jconvert(community, to = "baseR", Income, Education)
#> Stripped the missing-value declarations from 2 variables:
#>   Income     (-99 "Refused", -98 "Don't know")
#>   Education  (-99 "Refused", -98 "Don't know")
#> 
#> This call changes community only if you assign the result:
#>   community <- jconvert(community, ...)
#> 
#> To change community directly, rerun with modify = TRUE:
#>   jconvert(community, ..., modify = TRUE)

# Scope by character vector (alternative form):
df5 <- jconvert(community, to = "baseR", vars = c("Income", "Education"))
#> Stripped the missing-value declarations from 2 variables:
#>   Income     (-99 "Refused", -98 "Don't know")
#>   Education  (-99 "Refused", -98 "Don't know")
#> 
#> This call changes community only if you assign the result:
#>   community <- jconvert(community, ...)
#> 
#> To change community directly, rerun with modify = TRUE:
#>   jconvert(community, ..., modify = TRUE)

# Suppress the notification (e.g. inside a script):
df6 <- jconvert(community, to = "baseR", missing.notice = FALSE)

if (FALSE) { # \dontrun{
# Convert with target inferred from joptions:
joptions(missing.convention = "spss")
df <- jconvert(df)   # converts any Stata-style columns to SPSS
} # }
```
