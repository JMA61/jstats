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
separator (`/`) bypass this setting and are taken literally.

If the `data` argument is omitted, the default data frame set by
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) is used.

## Usage

``` r
jsave(data, file, overwrite = FALSE, preserve.udm = TRUE)
```

## Arguments

- data:

  A data frame (unquoted). If omitted, uses the default set by
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md).

- file:

  Character string. The filename with extension (e.g. `"mydata.sav"`) or
  a full file path. Use forward slashes in file paths.

- overwrite:

  Logical. If `TRUE`, overwrites an existing file without prompting. If
  `FALSE` (default), prompts for confirmation in interactive sessions.
  In non-interactive sessions, stops with an error.

- preserve.udm:

  Logical. If `TRUE` (the default), missing-value declarations are
  written as they stand; formats that cannot store them (notably Excel
  and CSV) drop the metadata, and SPSS-style codes such as -99 then read
  back as ordinary numbers. If `FALSE`, those codes are blanked to plain
  NA before writing, so they become empty cells. Mirrors the
  `preserve.udm` argument of
  [`jload`](https://jma61.github.io/jstats/reference/jload.md). The
  pre-flight checks for the .sav, .dta, and .xpt formats run before this
  step, so a missing-value form a target format cannot represent is
  still reported and blocked rather than silently dropped.

## Value

Invisibly returns `NULL`. Called for its side effect of writing a file
to disk.

## Details

**File paths:** Use forward slashes (`/`) in file paths. If you copy a
path from Windows File Explorer, replace the backslashes with forward
slashes. R does not accept single backslashes in file paths.

**File location:**

- If the path contains a directory separator, the file is saved to that
  exact location.

- If the path is a bare filename and `joptions("data.dir")` is set, the
  file is saved to that folder (auto-created if it doesn't yet exist).

- If the path is a bare filename and `joptions("data.dir")` is unset
  (the default), the file is saved to the working directory.

**Format notes:**

- SPSS (`.sav`) and Stata (`.dta`) preserve variable labels and value
  labels.

- Excel (`.xlsx`) and CSV (`.csv`) do not preserve variable or value
  labels.

- R native (`.rds`) preserves the data frame exactly as it exists in R,
  including all attributes.

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
#> Saved community to /tmp/RtmpVrJY1V/community.sav (SPSS format; 103 cases, 15 variables)

if (FALSE) { # \dontrun{
# The file extension determines the format ---
# the same data frame can be saved in any supported format
jsave(community, "community.sav")         # SPSS
jsave(community, "community.xlsx")        # Excel
jsave(community, "community.csv")         # CSV
jsave(community, "community.rds")         # R native

# Stata and SAS formats cannot carry community's SPSS-form missing-value
# declarations -- convert first (jsave() pre-flights this and says so)
jsave(jconvert(community, to = "stata"), "community.dta")   # Stata
jsave(jconvert(community, to = "baseR"), "community.xpt")   # SAS interchange

# Using juse() default
jsave(, "community.sav")

# Full file path
jsave(community, "C:/Output/community.sav")
} # }
```
