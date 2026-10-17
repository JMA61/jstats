# Save a data frame to a file

`jsave()` writes a data frame to a file. Supports SPSS (`.sav`), Stata
(`.dta`), SAS interchange (`.xpt`), Excel (`.xlsx`), CSV (`.csv`), and
R's native `.rds` format.

The file format is determined entirely by the file extension you provide
— for example, `"mydata.sav"` saves as SPSS, `"mydata.dta"` saves as
Stata, and `"mydata.xlsx"` saves as Excel. Changing the extension
changes the format.

By default, `jsave()` writes bare-filename saves to the working
directory, matching base R's
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) and
[`write.csv()`](https://rdrr.io/r/utils/write.table.html). To save into
a subfolder, set
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md)`(data.dir = "...")`
once per session (or in `.Rprofile`). Filenames containing a directory
separator (`/`, or a backslash) bypass this setting and are taken
literally.

If the `data` argument is omitted, the default data frame set by
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) is used.

## Usage

``` r
jsave(
  data,
  file,
  overwrite = FALSE,
  preserve.declarations = TRUE,
  clean.names = FALSE
)
```

## Arguments

- data:

  A data frame (unquoted). If omitted, uses the default set by
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md).

- file:

  Character string. The filename with extension (e.g. `"mydata.sav"`) or
  a full file path. Use forward slashes in file paths. If the extension
  is omitted, `.rds` is used and added to the filename.

- overwrite:

  Logical. If `TRUE`, overwrites an existing file without prompting. If
  `FALSE` (default), prompts for confirmation in interactive sessions.
  In non-interactive sessions, stops with an error. In a script, state
  it explicitly: `jsave(mydata, "mydata.rds", overwrite = TRUE)`.
  Otherwise, if the file already exists and the script was run by
  pasting or with RStudio's Run button, the call stops with an error.

- preserve.declarations:

  Logical. If `TRUE` (the default), missing-value declarations are
  written as they stand; formats that cannot store them (notably Excel
  and CSV) drop the metadata, and SPSS-style codes such as -99 then read
  back as ordinary numbers, while a missing-value form that .sav, .dta,
  or .xpt cannot represent stops the save before anything is written. If
  `FALSE`, every declared missing value – an SPSS-style code, or a
  Stata-style or SAS-style marker – is made plain NA before writing, in
  the file only (the data frame is not changed), and a note gives the
  number of cells. This happens before the .sav, .dta, and .xpt checks,
  so a form those formats cannot represent no longer stops the save.
  Mirrors the `preserve.declarations` argument of
  [`jload`](https://jma61.github.io/jstats/reference/jload.md). The
  haven package and its documentation call these user-defined missing
  values.

- clean.names:

  Logical. For `.sav`, `.dta` and `.xpt`. If `FALSE` (the default), a
  variable name the format cannot hold stops the save, listing every
  such name, why, and the name it would be given. If `TRUE`, those names
  are changed in the file only, the way
  [`jload`](https://jma61.github.io/jstats/reference/jload.md) changes
  names R cannot use; the data frame keeps its own names, each old name
  becomes the variable's label in the file where it has none, and a note
  lists the changes.

## Value

Invisibly returns `NULL`. Called for its side effect of writing a file
to disk.

## Details

**File paths:** Use forward slashes (`/`) in file paths. If you copy a
path from Windows File Explorer, replace the backslashes with forward
slashes. R does not accept single backslashes in file paths: inside
quoted text it reads a backslash and the letter after it as one special
character. `jsave()` stops on such a path, before anything is written,
and shows it written with forward slashes.

**File location:**

- If the path contains a directory separator, the file is saved to that
  exact location; the folder must already exist.

- If the path is a bare filename and the `data.dir` setting in
  [`joptions`](https://jma61.github.io/jstats/reference/joptions.md) is
  set, the file is saved to that folder
  ([`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
  creates it when the setting is made; it is created again here if it
  has been removed since).

- If the path is a bare filename and the `data.dir` setting in
  [`joptions`](https://jma61.github.io/jstats/reference/joptions.md) is
  unset (the default), the file is saved to the working directory.

**Format notes:**

- SPSS (`.sav`) and Stata (`.dta`) preserve variable labels and value
  labels.

- Excel (`.xlsx`) and CSV (`.csv`) do not preserve variable or value
  labels.

- R format (`.rds`) preserves the data frame exactly as it exists in R,
  including all attributes.

- R format (`.rds`) also carries the active classification registrations
  (see [`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md),
  [`jnumeric`](https://jma61.github.io/jstats/reference/jnumeric.md),
  [`jcount`](https://jma61.github.io/jstats/reference/jcount.md), and
  [`jlikert`](https://jma61.github.io/jstats/reference/jlikert.md)),
  which [`jload`](https://jma61.github.io/jstats/reference/jload.md)
  restores. Other formats cannot store them, and a note says so when any
  are lost.

- Before writing `.sav`, `.dta`, or `.xpt`, `jsave()` checks for
  anything the format cannot store and stops, naming every problem at
  once: complex, raw, list, or POSIXlt columns; missing values of a form
  the format cannot hold (Stata-style in `.sav`, SPSS-style in `.dta`,
  either in `.xpt`); and, for `.sav`, more than three declared codes, or
  a range plus more than one code, on one column. No file is written
  until the problems are fixed. A missing-value form the format cannot
  hold can also be saved as plain NA with
  `preserve.declarations = FALSE`, which the message offers beside the
  conversion.

- SPSS (`.sav`), Stata (`.dta`), SAS interchange (`.xpt`) and CSV
  (`.csv`) have no missing value for text: a text variable's missing
  cells are saved as blank text, and read back as blank, not missing. A
  note says so when it happens. R format (`.rds`) and Excel (`.xlsx`)
  keep them missing. In a CSV file the same holds for a factor, which is
  written as its labels.

- Variable names each format can hold: SPSS (`.sav`), a letter or @
  first, then letters, digits and . \_ \$ \# @, not ending in a period,
  at most 64 bytes, not a word SPSS reserves (ALL, AND, BY, EQ, GE, GT,
  LE, LT, NE, NOT, OR, TO, WITH), and no two that differ only in case;
  Stata (`.dta`), a letter or underscore first, then letters, digits and
  underscores, at most 32 characters, not a word Stata reserves (such as
  `long`, `in`, `byte`); SAS (`.xpt`), the letters A to Z, digits and
  underscores, not a digit first, at most 32 characters, and no two that
  differ only in case. A name outside these rules stops the save, naming
  every one at once, unless `clean.names = TRUE`.

- Labels each format shortens: SPSS keeps 256 bytes of a variable label
  and 120 of a value label; Stata keeps 80 characters of a variable
  label and of the data frame's label; SAS interchange keeps 40
  characters of the data frame's label. A note says what was shortened
  in the file; the data frame keeps its labels whole.

- An Excel sheet holds 1,048,575 cases below the names row and 16,384
  variables; a larger data frame stops with lines that save it in
  another format.

- Inside an `.xpt` file the SAS dataset is named after the file, changed
  to a SAS name when the file's name is not one (a note says so).

- A CSV file is written in UTF-8. When it holds a character beyond plain
  ASCII (an accented letter, a curly apostrophe, a dash), it starts with
  the UTF-8 byte-order mark, as Excel's own "CSV UTF-8" does, so that
  Excel opens it with those characters intact: without the mark, Excel
  on Windows reads a CSV file in Windows-1252. A file of plain ASCII has
  no mark.
  [`jload()`](https://jma61.github.io/jstats/reference/jload.md) reads
  the mark as the start of a UTF-8 file.

- Stata files are written as version 14 format.

- Legacy Excel format (`.xls`) is not supported for saving. Use `.xlsx`
  instead.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
# A runnable save into R's session temporary folder
jsave(community, file.path(tempdir(), "community.sav"), overwrite = TRUE)
#> Saved community to /tmp/RtmpKVXU0z/community.sav
#> (SPSS format; 103 cases, 15 variables)
jsave(data = community, file.path(tempdir(), "community.sav"),
      overwrite = TRUE)                   # the data frame given by name
#> Saved community to /tmp/RtmpKVXU0z/community.sav
#> (SPSS format; 103 cases, 15 variables)

if (FALSE) { # \dontrun{
# The file extension determines the format ---
# the same data frame can be saved in any supported format
jsave(community, "community.sav")         # SPSS
jsave(community, "community.xlsx")        # Excel
jsave(community, "community.csv")         # CSV
jsave(community, "community.rds")         # R format

# Using juse() default
juse(community)
jsave("community.sav")

# Full file path
jsave(community, "C:/Output/community.sav")

# Stata and SAS formats cannot carry community's SPSS-style missing-value
# declarations -- convert first (jsave() pre-flights this and says so)
jconvert(community, to = "stata", modify = TRUE)
jsave(community, "community.dta")                  # Stata
jconvert(community, to = "baseR", modify = TRUE)
jsave(community, "community.xpt")                  # SAS interchange
} # }
```
