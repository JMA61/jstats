# Set or display session-level package options

Controls session-wide settings that affect how the package handles
missing-value information and related conventions. `joptions`
complements
[`joutput`](https://jma61.github.io/jstats/reference/joutput.md):
joutput governs output verbosity and tiering, while joptions holds
session-wide conventions plus a small number of per-function display
defaults (currently the
[`jcorr()`](https://jma61.github.io/jstats/reference/jcorr.md) cell
layout). Settings are read fresh on each function call: changing a
setting after data has been loaded does not retroactively transform data
already in memory.
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md) is
the explicit transform path for data already in the workspace.

## Usage

``` r
joptions(
  missing.convention = NULL,
  udm.convention.codes = NULL,
  data.dir = NULL,
  corr.layout = NULL,
  quiet = FALSE
)
```

## Arguments

- missing.convention:

  One of `"none"`, `"spss"`, or `"stata"`. See Slots.

- udm.convention.codes:

  Numeric vector, length 1 to 3. See Slots.

- data.dir:

  Character string (length 1), or `NULL`. See Slots.

- corr.layout:

  One of `"wide"` or `"stacked"`, or `NULL`. See Slots.

- quiet:

  Logical; default FALSE. When TRUE, joptions() applies the change
  silently, suppressing both the status panel and the convention nudge.
  A bare joptions() status query always prints regardless of quiet.

## Value

Invisibly returns `NULL`. Called for the side effect of updating session
options and printing the status panel.

## Slots

- missing.convention:

  Character, length 1. One of `"none"`, `"spss"`, or `"stata"`. Default:
  `"none"`. `"none"` preserves loaded data as-is (no automatic
  conversion between user-defined missing value (UDM) representations at
  load time). `"spss"` or `"stata"` opts into load-time auto-conversion
  via [`jload`](https://jma61.github.io/jstats/reference/jload.md), and
  also supplies the target convention for fresh UDM declarations on
  columns with no existing convention.

- udm.convention.codes:

  Numeric vector, length 1 to 3, whole numbers, no duplicates. Sign
  unconstrained. Default: `c(-99, -98, -97)`. The recommended UDM code
  set used by
  [`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md)
  when translating Stata-style missing values (`.a`, `.b`, `.c`, `.d`)
  into SPSS-form numeric codes, and by the load-time diagnostic for
  convention-matched detection.

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
  patterns). Filenames containing a directory separator (`/`) bypass
  this setting and are taken literally.

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

## Call patterns

- `joptions()`:

  Print the current settings panel.

- `joptions(NULL)`:

  Reset all slots to defaults, then print the panel.

- `joptions(slot = value, ...)`:

  Set one or more slots, then print the panel. Passing `slot = NULL` as
  a named argument leaves that slot at its current value – useful for
  setting one slot without touching another. To reset a single slot to
  its default, pass the default value explicitly (e.g.
  `joptions(missing.convention = "none")`). Because `data.dir`'s default
  is `NULL` – which already means "leave alone" – it is cleared instead
  with `data.dir = ""`.

## Environment-scan notice

Setting `missing.convention` to `"spss"` or `"stata"` triggers a
one-time scan of
[`globalenv()`](https://rdrr.io/r/base/environment.html) for data frames
whose predominant UDM convention differs from the newly-set value. When
mismatches exist, a one-line notice lists the affected data frames and
suggests
[`jconvert`](https://jma61.github.io/jstats/reference/jconvert.md) for
alignment. The notice is informational; nothing is changed. Plain data
frames with no UDM-bearing columns – including the course datasets in
their standard form – do not trigger the notice.

## See also

[`joutput`](https://jma61.github.io/jstats/reference/joutput.md) for
output-verbosity settings;
[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview.

## Examples

``` r
joptions()                                        # show current settings
#> Options Settings
#> User-defined missing values (UDMs) convention: None selected
#> UDM convention codes: -99, -98, -97
#> Data folder: Working directory
#> Correlation layout: wide
#> 
joptions(missing.convention = "spss")             # set, panel, nudge
#> Options Settings
#> User-defined missing values (UDMs) convention: SPSS
#> UDM convention codes: -99, -98, -97
#> Data folder: Working directory
#> Correlation layout: wide
#> 
joptions(udm.convention.codes = c(-99, -98))      # set, panel, no nudge
#> Options Settings
#> User-defined missing values (UDMs) convention: SPSS
#> UDM convention codes: -99, -98
#> Data folder: Working directory
#> Correlation layout: wide
#> 
joptions(data.dir = "Data")                       # set save/load folder
#> Options Settings
#> User-defined missing values (UDMs) convention: SPSS
#> UDM convention codes: -99, -98
#> Data folder: Data (will be created on first save)
#> Correlation layout: wide
#> 
joptions(missing.convention = "stata",
         udm.convention.codes = c(-99, -98, -97)) # set both
#> Options Settings
#> User-defined missing values (UDMs) convention: Stata
#> UDM convention codes: -99, -98, -97
#> Data folder: Data (will be created on first save)
#> Correlation layout: wide
#> 
joptions(missing.convention = "spss",
         udm.convention.codes = NULL)             # set mc, leave codes
#> Options Settings
#> User-defined missing values (UDMs) convention: SPSS
#> UDM convention codes: -99, -98, -97
#> Data folder: Data (will be created on first save)
#> Correlation layout: wide
#> 
joptions(NULL)                                    # reset all to defaults
#> Options Settings
#> User-defined missing values (UDMs) convention: None selected
#> UDM convention codes: -99, -98, -97
#> Data folder: Working directory
#> Correlation layout: wide
#> 
```
