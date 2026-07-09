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
  preserve.udm = TRUE,
  udm.notice = NULL,
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
  interactive sessions. In non-interactive sessions, overwrites with a
  warning message.

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

- preserve.udm:

  Logical. If `TRUE` (default), user-defined missing values arriving
  with the file are preserved: SPSS-style codes such as -99 keep their
  original numeric values in the data frame, with metadata attached so
  the package's analysis functions still treat them as missing, and
  Stata-style tagged values (`.a`, `.b`, ...) are kept as read. If
  `FALSE`, both forms are converted to plain `NA` on import and the
  metadata is stripped. Applies to any loaded file whose columns carry
  missing-value declarations — typically `.sav`, `.dta`, and `.sas7bdat`
  files, and `.rds` files saved from such data. For `.sav` files, `TRUE`
  corresponds to haven's `user_na = TRUE`.

- udm.notice:

  Per-call override for the user-defined missing value (UDM)
  notification. `NULL` (default) defers to the setting from
  [`joutput()`](https://jma61.github.io/jstats/reference/joutput.md).
  `TRUE` prints the notification on every load with UDM-bearing
  variables; `FALSE` suppresses it. Under the default (standard) and
  full output levels it prints on every such load; minimal suppresses
  it. See
  [`?joutput`](https://jma61.github.io/jstats/reference/joutput.md) for
  the full toggle behavior.

- quiet:

  Logical; default FALSE. When TRUE, suppresses jload()'s informational
  messages (the directory-resolution note, file found, load summary,
  default-data note, and the UDM narrative, overriding udm.notice).
  Errors, warnings, the multi-sheet advisory, and the overwrite prompt
  are still shown.

## Value

Invisibly returns the loaded data frame. The primary effect is assigning
the data frame in the calling environment.

## Details

**File paths:** Use forward slashes (`/`) in file paths. If you copy a
path from Windows File Explorer, replace the backslashes with forward
slashes. R does not accept single backslashes in file paths.

**File search order:**

1.  If the path contains a directory separator (`/`), the path is used
    directly.

2.  If the path is a bare filename, `jload()` checks: (a) the folder
    named by `joptions("data.dir")` if it is set and exists; (b) the
    working directory.

**Auto-naming:** The data frame name is derived from the filename by
stripping the extension. If the resulting name starts with a digit
(which R does not allow as a variable name), you must supply the `name`
argument.

**Excel files:** Excel files (`.xlsx`, `.xls`) do not contain variable
or value labels. The data will be loaded as plain numeric, character, or
logical columns. Use
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md) to
add labels after loading if needed.

**Coded missing values:** When `check.missing = TRUE`, the function
scans numeric variables for values that appear to be coded missing
values. Only whole-number values are considered (coded missing values
are always integers like -99, 999, etc.). Two detection methods are
used:

- For SPSS files, user-defined missing values stored in the file
  metadata are reported with high confidence.

- A heuristic scan detects negative values among otherwise positive data
  and extreme outlier values (5x the range of other values).

Detected values are reported but not changed. Use
[`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md) to
convert them to `NA` if needed.

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
