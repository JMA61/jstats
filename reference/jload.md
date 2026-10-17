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
  skip = 0,
  header = TRUE,
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
  package (e.g. `community`, `clinic`) by bare name, or a shipped
  example file by its file name (`"community_spss.sav"`), bypassing the
  disk search. Use this when a same-named file in the working directory
  or data folder would otherwise shadow the shipped copy. If `FALSE`
  (default), a matching disk file takes precedence and the shipped copy
  is used only when no file matches. `file` must be a name with no path
  when `package = TRUE`, and a dataset's name has no extension.

- check.missing:

  Logical. If `TRUE` (default), scans numeric variables for values that
  look like coded missing values (e.g. -99, 999) and reports them. Set
  to `FALSE` to skip this check.

- sheet:

  For Excel files only. The sheet to read — either a sheet name
  (character) or sheet number (integer). Defaults to the first sheet. If
  the file has multiple sheets and `sheet` is not specified, a message
  lists the available sheets.

- skip:

  For Excel and CSV files. The number of rows of the sheet, or lines of
  the file, above the variable names: a title, a blank row, a note.
  Default 0. When the first row of a sheet looks like a title, a note
  shows the call with the `skip` it needs; a CSV file in that shape
  stops with the same call.

- header:

  For Excel and CSV files. `TRUE` (default) reads the first row of the
  sheet, or line of the file, as the variable names. `FALSE` reads it as
  the first case, for a file with no names row, and names the variables
  `V1`, `V2`, and so on, as base R's `read.csv(header = FALSE)` does.
  Every other format carries its own variable names, so `header = FALSE`
  stops there. When every name read is a number, a note shows the call
  with `header = FALSE`; writing `header = TRUE` in the call says the
  numbers are the names (years, say), and the note is not shown.

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
  file shadowed a shipped dataset, the note that an existing object was
  replaced, and the notes on what the read changed or found (variable
  names changed, a title row, names that are all numbers, rows and
  columns that may not be data, a CSV file's encoding) are still shown,
  as is the coded-missing scan report; turn that off with
  `check.missing = FALSE`.

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
slashes. R does not accept single backslashes in file paths: inside
quoted text it reads a backslash and the letter after it as one special
character (a backslash before t is a tab), so the path that arrives is
not the one typed. `jload()` stops on such a path and shows it written
with forward slashes.

**CSV files:** A CSV file with one column keeps its empty lines: each is
a case whose one cell is empty, which is how a missing value is written
there. In a file with two or more columns an empty line is not a case.
An empty cell in a text variable is read as blank text, never as missing
(see [`jsave`](https://jma61.github.io/jstats/reference/jsave.md)).

Before a CSV file is read, every line's values are counted. A first line
with fewer values than the lines below it (a title above the names, or a
name missing), and a later line with more values than the first, stop
the load with the line and what to do: read as they are, R would turn
the first values of every line into row names, or split the long line
into two cases, and say nothing. A file whose values are separated by
semicolons, as Excel saves them in many European settings, stops with
the base R line that reads it. A file that is not in UTF-8 (one saved by
Excel on Windows as "CSV (Comma delimited)" is in Windows-1252) is read
in Windows-1252, and a note says so. Read with `header = FALSE`, a file
has no names line, so each line is measured against the number of values
most lines hold: a line holding more stops the load, and one holding
fewer is read with its last cells empty.

**A file with no names row:** A CSV file or a sheet whose first row is
data loses that case to the variable names, which are then numbers (`1`
becomes `X1`). When every name read is a number, or empty, a note says
the row they came from may be the first case and shows the call that
reads it as one: `jload("scores.csv", header = FALSE)`, the variables
named `V1`, `V2`, and so on.

**Rows and columns that may not be data:** A sheet can hold rows with
nothing in them, a column with no name and nothing in it, and lines of
text below the data, such as a source or a footnote; a CSV file can hold
a line of commas alone, an empty column from a comma at the end of each
line, and the row numbers R's
[`write.csv()`](https://rdrr.io/r/utils/write.table.html) writes in a
first column with no name. Each is read as data, as a case or a
variable, and a note names them by their place in the file, with the
case numbers or the variable names; when footnotes turned a variable of
numbers into text, it says so. Nothing is removed. An empty line in a
CSV file of one column is a case with a missing value, and is not named.

**Variable names from other software:** A file from outside R can hold
names R cannot use as they are: `2024 score`, `Age (years)`, an empty
header, two columns with the same name, a word R reserves (`if`,
`TRUE`), an SPSS name such as `Q1@A`, a Stata name such as `_merge`. For
every format but `.rds`, each such name is changed: spaces and symbols
at either end are dropped, any other run of characters that are not
letters, digits or underscores becomes one underscore, a name that
starts with a digit or an underscore or is a reserved word gets an `X`
in front, an empty name becomes `V` and its column's position, a
repeated name gets `_2`, and a changed name is kept to 32 characters. So
`2024 score` becomes `X2024_score` and `Age (years)` becomes
`Age_years`. A name R can use as it is is never changed. The original
name becomes the variable's label, unless the variable has a label of
its own, and a note lists every change. An `.rds` file is returned as it
was saved.

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
argument; the error offers one (`2024.csv` is offered `name = "X2024"`).
Other characters R does not allow in a name, such as spaces and hyphens,
are changed as variable names are (see above): `"my data-1.sav"` loads
as `my_data_1`.

**Excel files:** Excel files (`.xlsx`, `.xls`) do not contain variable
or value labels. The data will be loaded as plain numeric, character, or
logical columns; a variable whose name was changed has its original name
as its label. Use
[`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md) to
add labels after loading if needed. Row 1 of the sheet is read as the
variable names; when the names are lower down, `skip` gives the number
of rows above them, and when there are none, `header = FALSE` reads row
1 as data. Each variable's type is read from every row of the sheet.

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

A value in the `missing.convention.codes` setting of
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md) (-99,
-98 and -97 by default) is flagged as well, whatever its size. A flagged
value whose value label suggests missingness (such as "Refused" or
"Don't know") is reported as label-only; one of the setting's codes, as
convention-matched; the rest as suspected. Flagged values are reported
but not changed. If they are missing values, declare them with
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

**Example files:** jstats also ships the `community` data as files, the
kind a collaborator might send: `community_spss.sav`,
`community_stata.dta` and `community_excel.xlsx`. When no file of that
name is in the data.dir folder or the working directory,
`jload("community_spss.sav")` reads the shipped one, and says so; the
name without its extension works too (`jload("community_spss")`). A file
of the same name on disk is read instead, with a note giving the call
that reads the shipped file:
`jload("community_spss.sav", package = TRUE)`.

**Variables named T or F:** At `joutput("full")` a note names a variable
called `T` or `F`. jstats reads it as the variable, but in base R `T`
and `F` also stand for `TRUE` and `FALSE`, and code run inside the data
frame – [`with()`](https://rdrr.io/r/base/with.html),
[`subset()`](https://rdrr.io/r/base/subset.html) – reads the variable in
their place.

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
jload("survey.xlsx", skip = 2)   # a title and a blank row above the names
jload("scores.csv", header = FALSE)   # no names row: V1, V2, ...

# CSV and R format
jload("community.csv")
jload("community.rds")

# Extension omitted -- jload searches for a matching file automatically
jload("community")

# The example files shipped with jstats, read by name
jload("community_spss.sav")
jload("community_excel.xlsx", package = TRUE)   # even beside a local copy

# Full file path
jload("C:/Projects/Data/community.dta")

# Quiet load (e.g. in a .Rprofile or startup script): suppresses the
# informational messages while still loading. Errors and warnings still show.
jload("community.rds", name = "MyData", quiet = TRUE)
} # }
```
