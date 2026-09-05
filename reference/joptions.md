# Set or display session-level package options

Controls session-wide settings that affect how the package handles
missing-value information and related conventions. `joptions`
complements
[`joutput`](https://jma61.github.io/jstats/reference/joutput.md):
joutput governs output verbosity and tiering, while joptions holds
session-wide conventions plus a small number of per-function display
defaults (the
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) cell
layout via `corr.layout`, and the
[`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)
missing-value range detail via `missing.detail`), and the width at which
runtime message prose wraps (`message.width`). Settings are read fresh
on each function call: changing a setting after data has been loaded
does not retroactively transform data already in memory.
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md) is
the explicit transform path for data already in the workspace.

## Usage

``` r
joptions(
  missing.convention = NULL,
  missing.convention.codes = NULL,
  data.dir = NULL,
  corr.layout = NULL,
  missing.detail = NULL,
  message.width = NULL,
  quiet = FALSE
)
```

## Arguments

- missing.convention:

  One of `"none"`, `"spss"`, `"stata"`, or `"sas"` (any capitalization
  is accepted). See Slots.

- missing.convention.codes:

  Numeric vector, length 1 to 3. See Slots.

- data.dir:

  Character string (length 1), or `NULL`. See Slots.

- corr.layout:

  One of `"wide"` or `"stacked"`, or `NULL`. See Slots.

- missing.detail:

  One of `"totals"`, `"per_code"`, or `"all"`, or `NULL`. See Slots.

- message.width:

  One of `"auto"`, `"narrow"`, `"medium"`, `"wide"`, a whole number
  between 40 and 120, or `NULL`. See Slots.

- quiet:

  Logical; default FALSE. When TRUE, joptions() applies the change
  silently, suppressing the settings echo, its pointer, and the
  convention nudge alike. A bare joptions() status query always prints
  regardless of quiet.

## Value

Invisibly returns `NULL`. Called for the side effect of updating session
options and printing the settings panel – in full for a status query or
a reset, or as an echo of the slots a setting call touched.

## Slots

- missing.convention:

  Character, length 1. One of `"none"`, `"spss"`, `"stata"`, or `"sas"`.
  Default: `"none"`, meaning no stated preference: loaded data is
  preserved as-is, and a call that would create a fresh missing-value
  declaration stops with a guided error asking you to choose a
  convention – the package never infers one. A set value states your
  working convention: it supplies the target for fresh missing-value
  declarations on columns with no existing convention, becomes the
  default target for
  [`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md)
  when `to` is not given, and is the reference point for the
  environment-scan notice (see below). Data already loaded is never
  changed by setting this;
  [`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md) is
  the explicit transform path.

- missing.convention.codes:

  Numeric vector, length 1 to 3, whole numbers, no duplicates. Sign
  unconstrained. Default: `c(-99, -98, -97)`. The recommended
  missing-value code set used by
  [`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md)
  when translating Stata-style or SAS-style missing values into
  SPSS-style numeric codes: the first tag letter (`.a` or `.A`) takes
  the first code, the second the second, and so on, so a column carrying
  more distinct tags than there are codes cannot be converted. Also the
  source of the value the `missing` keyword creates in a
  [`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md) or
  [`jencode`](https://jma61.github.io/jstats/reference/jencode.md) map
  under an SPSS-style convention (the first code).

- data.dir:

  Character string (length 1), or `NULL`. Default: `NULL`. When `NULL`,
  [`jsave`](https://jma61.github.io/jstats/reference/jsave.md) writes
  bare-filename saves to the working directory and
  [`jload`](https://jma61.github.io/jstats/reference/jload.md) searches
  the working directory. When set, names a folder (relative to the
  working directory) used as both the save target for bare-filename
  saves and as the first directory searched on bare-filename loads. The
  folder is auto-created on first save if it doesn't already exist
  (nested paths are created in full). To clear a previously-set folder
  back to this default, pass `data.dir = ""` (an empty string); passing
  `data.dir = NULL` leaves the current setting unchanged (see Call
  patterns). Filenames containing a directory separator (a forward
  slash, or a backslash on Windows) bypass this setting and are taken
  literally.

- corr.layout:

  Character, length 1. One of `"wide"` or `"stacked"`. Default:
  `"wide"`. The default cell layout for
  [`jcorr`](https://jma61.github.io/jstats/reference/jcorr.md) when
  three or more variables are correlated: `"wide"` puts r and p on one
  line with N beneath; `"stacked"` stacks r, p, and N on three lines for
  a narrower table that fits more variables. A per-call `layout`
  argument to
  [`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md)
  overrides this. It lives here rather than in
  [`joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  because it is specific to one function's output, not a tiered
  analysis-content toggle.

- missing.detail:

  Character, length 1. One of `"totals"`, `"per_code"`, or `"all"`.
  Default: `"per_code"`. Governs how much of a declared missing-value
  RANGE [`jfreq`](https://jma61.github.io/jstats/reference/jfreq.md)
  spells out in its Missing block. `"totals"` collapses the whole band
  into one row; `"per_code"` prints one row per observed in-band value,
  at most 10, with the remainder gathered into a single line at the foot
  of the block; `"all"` prints every observed in-band value with no cap.
  Declared discrete codes always print in full at every setting – the
  cap applies only to values reached by a range. A per-call
  `missing.detail` argument to
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md)
  overrides this. Like `corr.layout` it lives here rather than in
  [`joutput`](https://jma61.github.io/jstats/reference/joutput.md)
  because it is specific to one function's output.

- message.width:

  Character or numeric, length 1. One of `"auto"`, `"narrow"` (50
  columns), `"medium"` (76), `"wide"` (90), or a whole number between 40
  and 120. Default: `"auto"`. The target width at which the package
  wraps runtime MESSAGE prose – errors, warnings and notes. `"auto"`
  follows the console pane, which R keeps current as the pane is
  resized, so it is resolved afresh for each message rather than fixed
  when it is set. A width outside 40 to 120 is refused rather than
  quietly adjusted. Analysis TABLES are not affected and do not reflow:
  prose can be re-wrapped without losing information, whereas breaking a
  correlation matrix mid-row would destroy the alignment that makes it
  readable.

## Call patterns

- `joptions()`:

  Print the full settings panel. The `missing.convention.codes` row is
  SPSS-convention detail and appears only while `missing.convention` is
  `"spss"`.

- `joptions(NULL)`:

  Reset all slots to defaults, then print the full panel – everything
  changed.

- `joptions(slot = value, ...)`:

  Set one or more slots, then echo only what the call touched: the slots
  named, plus `missing.convention` whenever `missing.convention.codes`
  is set (the codes are read in light of the convention), and plus
  `missing.convention.codes` when `missing.convention` is set to
  `"spss"` (under any other convention the codes are dormant and the row
  is omitted), closed by a pointer to `joptions()` for the full panel.
  The other four slots are independent and are not pulled in. Passing
  `slot = NULL` as a named argument leaves that slot at its current
  value – useful for setting one slot without touching another – and
  echoes that unchanged value back. To reset a single slot to its
  default, pass the default value explicitly (e.g.
  `joptions(missing.convention = "none")`). Because `data.dir`'s default
  is `NULL` – which already means "leave alone" – it is cleared instead
  with `data.dir = ""`.

## Environment-scan notice

Setting `missing.convention` to `"spss"`, `"stata"`, or `"sas"` triggers
a one-time scan of
[`globalenv()`](https://rdrr.io/r/base/environment.html) for data frames
whose missing-value convention differs from the newly-set value. When
mismatches exist, a notice lists the affected data frames and suggests
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md):
frames whose declared columns all carry one convention read "use X-style
missing values", while frames with a genuine internal majority read
"predominantly use". The notice is informational; nothing is changed.
Plain data frames with no declared missing values – including the course
datasets in their standard form – do not trigger the notice.

## See also

[`joutput`](https://jma61.github.io/jstats/reference/joutput.md) for
output-verbosity settings;
[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview.

## Examples

``` r
joptions()                                        # show current settings
#> Options Settings
#> Missing-value convention: SPSS-style
#> SPSS-style missing value codes: -99, -98, -97
#> Data folder: Working directory
#> Correlation layout: wide
#> Missing-value detail: per_code
#> Message width: Auto (currently 79)
#> 

# Setting a convention echoes the convention and its codes, then scans
# the workspace and notes any data frames whose missing-value
# convention differs (see the Environment-scan notice section):
joptions(missing.convention = "spss")             # set, echo, scan notice
#> Options Settings
#> Missing-value convention: SPSS-style
#> SPSS-style missing value codes: -99, -98, -97
#> Run joptions() to see all settings.
#> 
joptions(missing.convention = "sas")              # SAS-style: .A, .B, ...
#> Options Settings
#> Missing-value convention: SAS-style
#> Run joptions() to see all settings.
#> 
joptions(missing.convention.codes = c(-99, -98))      # set, echo, no scan
#> Options Settings
#> Missing-value convention: SAS-style
#> SPSS-style missing value codes: -99, -98
#> Run joptions() to see all settings.
#> 
joptions(data.dir = "Data")                       # set save/load folder
#> Options Settings
#> Data folder: Data (will be created on first save)
#> Run joptions() to see all settings.
#> 
joptions(message.width = 60)                      # wrap message prose at 60
#> Options Settings
#> Message width: 60
#> Run joptions() to see all settings.
#> 
joptions(message.width = "narrow")                # preset width (50 columns)
#> Options Settings
#> Message width: Narrow (50)
#> Run joptions() to see all settings.
#> 
joptions(message.width = "auto")                  # follow the console pane
#> Options Settings
#> Message width: Auto (currently 79)
#> Run joptions() to see all settings.
#> 
joptions(missing.convention = "stata",
         missing.convention.codes = c(-99, -98, -97)) # set both
#> Options Settings
#> Missing-value convention: Stata-style
#> SPSS-style missing value codes: -99, -98, -97
#> Run joptions() to see all settings.
#> 
joptions(missing.convention = "spss",
         missing.convention.codes = NULL)             # set mc, leave codes
#> Options Settings
#> Missing-value convention: SPSS-style
#> SPSS-style missing value codes: -99, -98, -97
#> Run joptions() to see all settings.
#> 
joptions(NULL)                                    # reset all to defaults
#> Options Settings
#> Missing-value convention: None selected
#> Data folder: Working directory
#> Correlation layout: wide
#> Missing-value detail: per_code
#> Message width: Auto (currently 79)
#> 
```
