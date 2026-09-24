# Load a data file into R

`jload()` reads a data file and assigns it as a data frame in your
environment. Supports SPSS (`.sav`), Stata (`.dta`), SAS (`.sas7bdat`,
`.xpt`), Excel (`.xlsx`, `.xls`), CSV (`.csv`), and R's native `.rds`
format.

The file format is determined entirely by the file extension — `jload()`
reads the extension (e.g. `.sav`, `.dta`, `.xlsx`) and uses the
appropriate reader automatically.

By default, `jload()` looks for the file in the working directory. If a
data folder is configured with `joptions(data.dir = ...)`, that folder
is searched first. If a full file path is provided, it is used directly.

The data frame is automatically named after the file (without the
extension). Use the `name` argument to specify a different name.

## Usage

``` r
jload(
  file,
  name = NULL,
  use = FALSE,
  overwrite = FALSE,
  package = FALSE,
  check.missing = TRUE,
  sheet = NULL,
  preserve.declarations = TRUE,
  missing.notice = NULL,
  quiet = FALSE
)
```

## Arguments

- file:

  Character string. The filename (e.g. `"mydata.sav"`) or a full file
  path (e.g. `"C:/Projects/mydata.sav"`). Use forward slashes in file
  paths. If the extension is omitted, `jload()` searches for common data
  file types automatically.

- name:

  Character string (optional). The name to assign the data frame in your
  environment. If omitted, the name is derived from the filename.

- use:

  Logical. If `TRUE`, automatically calls
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) on the
  loaded data frame to set it as the default for jstats functions.
  Default is `FALSE`.

- overwrite:

  Logical. If `TRUE`, overwrites an existing object with the same name
  without prompting. If `FALSE` (default), prompts for confirmation in
  interactive sessions. In non-interactive sessions, overwrites and says
  so in a note. In a script, state it explicitly:
  `jload("mydata.rds", overwrite = TRUE)`. Otherwise, if the name
  already exists in your environment, and the script was run by pasting
  or with RStudio's Run button, the call stops with an error.

- package:

  Logical. If `TRUE`, loads a jstats example dataset shipped in the
  package (e.g. `community`, `clinic`) by bare name, bypassing the disk
  search. Use this when a same-named file in the working directory or
  data folder would otherwise shadow the shipped dataset. If `FALSE`
  (default), a matching disk file takes precedence and the shipped
  dataset is used only when no file matches. `file` must be a bare name
  with no path or extension when `package = TRUE`.

- check.missing:

  Logical. If `TRUE` (default), scans numeric variables for values that
  look like coded missing values (e.g. -99, 999) and reports them. Set
  to `FALSE` to skip this check.

- sheet:

  For Excel files only. The sheet to read — either a sheet name
  (character) or sheet number (integer). Defaults to the first sheet. If
  the file has multiple sheets and `sheet` is not specified, a message
  lists the available sheets.

- preserve.declarations:

  Logical. If `TRUE` (default), declared missing values arriving with
  the file are preserved: SPSS-style codes such as -99, and declared
  ranges, keep their original numeric values in the data frame, with the
  declaration attached so the package's analysis functions still treat
  them as missing, and Stata-style tagged values (`.a`, `.b`, ...) are
  kept as read. If `FALSE`, both forms are converted to plain `NA` on
  import and the declarations are removed; value labels are kept.
  Applies to any loaded file whose columns carry missing-value
  declarations — typically `.sav`, `.dta`, and `.sas7bdat` files, and
  `.rds` files saved from such data. For `.sav` files, `TRUE`
  corresponds to haven's `user_na = TRUE`. The haven package and its
  documentation call these user-defined missing values.

- missing.notice:

  Per-call override for the missing-value notification. `NULL` (default)
  defers to the setting from
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).
  `TRUE` prints the notification, in its full form, on any load with
  declared missing values; `FALSE` suppresses it. Under the default
  (standard) and full output levels the first such load in a session
  prints the full notification and later loads print a compact form (the
  variable inventory, plus the convention note when one applies, without
  the guidance lines); minimal suppresses the notification. See
  [`?joutput`](https://jma61.github.io/jstats/reference/joutput.md) for
  the full toggle behavior.

- quiet:

  Logical; default FALSE. When TRUE, suppresses jload()'s informational
  messages (the directory-resolution note, file found, load summary,
  default-data note, registration notes, and the narrative about
  declared missing values, overriding missing.notice). Errors, warnings,
  the multi-sheet advisory, the overwrite prompt, the note that a local
  file shadowed a shipped dataset, and the note that an existing object
  was replaced are still shown, as is the coded-missing scan report;
  turn that off with `check.missing = FALSE`.

## Value

Invisibly returns `NULL`; jload() is called for its side effects. The
loaded data frame is placed in the calling environment under the file's
name (or `name`), and any classification registrations saved with an
.rds file are restored for that name. Loading a file that carries none
clears any registrations set this session under that name, with a note
saying so. Do not assign the result: `x <- jload("mydata.rds")` binds
only `NULL`, while the data frame still arrives under its own name.

## Details

**File paths:** Use forward slashes (`/`) in file paths. If you copy a
path from Windows File Explorer, replace the backslashes with forward
slashes. R does not accept single backslashes in file paths.

**File search order:**

1.  If the path contains a directory separator (`/`, or a backslash),
    the path is used directly.

2.  If the path is a bare filename, `jload()` checks: (a) the folder
    named by the `data.dir` setting in
    [`joptions`](https://jma61.github.io/jstats/reference/joptions.md)
    if it is set and exists; (b) the working directory.

When the extension is omitted, both locations are searched for every
supported extension, and more than one match (two extensions, or the
same file in both locations) is an error that asks for the extension. If
nothing matches on disk, a bare name falls back to a shipped example
dataset of that name (see below).

**Auto-naming:** The data frame name is derived from the filename by
stripping the extension. If the resulting name starts with a digit
(which R does not allow as a variable name), you must supply the `name`
argument. Other characters R does not allow in a name, such as spaces
and hyphens, become dots: `"my data-1.sav"` loads as `my.data.1`.

**Excel files:** Excel files (`.xlsx`, `.xls`) do not contain variable
or value labels. The data will be loaded as plain numeric, character, or
logical columns. Use
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md) to
add labels after loading if needed.

**Missing-value declarations:** Missing-value declarations are stored in
the file itself, but they only survive the trip back if the reader
requests them. `jload()` always does, so declarations written by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) are
present after every jstats load (unless
`preserve.declarations = FALSE`). Other ways of reading the same file
may convert the declared cells to plain `NA` and discard the
declarations, so the same file can show different numbers of valid cases
depending on how it was read.

**Coded missing values:** When `check.missing = TRUE`, the function
scans numeric variables for values that look like coded missing values
but are not declared as missing. (Declared missing values are reported
in the load's own notification, never by the scan.) Only whole-number
values are considered. A value is flagged when it is

- a negative number at least three times the size of the variable's
  largest non-negative value (-99 on a 1-to-5 scale), or

- at least five times the size of every other value in the variable (999
  on a 1-to-7 scale).

A flagged value whose value label suggests missingness (such as
"Refused" or "Don't know") is reported as label-only; the rest are
reported as suspected. Flagged values are reported but not changed. If
they are missing values, declare them with
[`jdeclare_missing`](https://jma61.github.io/jstats/reference/jdeclare_missing.md),
which keeps the codes and their labels; the report shows the call.

**Package example datasets and .rda / .RData files:** `jload()` opens
the example datasets shipped with jstats – currently `community` and
`clinic` – by bare name: `jload("community")`. These ship inside the
package as .rda files, but the bare-name load is a lookup of the shipped
dataset, not a file read, and it works only for package datasets. It
does not extend to .rda or .RData files generally: naming the extension
(`jload("community.rda")`) or pointing at any other .rda or .RData file
is refused with a pointer to base R's
[`load()`](https://rdrr.io/r/base/load.html), because such files can
hold several objects under names of their own choosing, outside jload's
one-data-frame contract. Note also that the shipped dataset is a
fallback: a file with a matching name in the working directory or
data.dir folder is opened instead of the shipped copy. Use
`package = TRUE` to force the shipped dataset.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
if (FALSE) { # \dontrun{
# SPSS
jload("community.sav")
jload("community.sav", use = TRUE)
jload("community.sav", name = "MySurvey")

# Stata
jload("community.dta")

# SAS
jload("community.sas7bdat")
jload("community.xpt")

# Excel
jload("community.xlsx")
jload("community.xlsx", sheet = "Wave2")
jload("community.xlsx", sheet = 2)

# CSV and R native
jload("community.csv")
jload("community.rds")

# Extension omitted -- jload searches for a matching file automatically
jload("community")

# Full file path
jload("C:/Projects/Data/community.dta")

# Quiet load (e.g. in a .Rprofile or startup script): suppresses the
# informational messages while still loading. Errors and warnings still show.
jload("community.rds", name = "MyData", quiet = TRUE)
} # }
```
