# Internal helper: build and render the jcomplete deletion preview

Constructs the row-level preview of what
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)'s
listwise deletion will drop and renders it. Reuses the masked analysis
copy (SPSS-form UDMs already set to NA) so the preview reflects exactly
what the filter excludes (Cross-cutting 5). The display frame carries a
leading `Row` column (original position, as
[`which()`](https://rdrr.io/r/base/which.html) gives), the registered
variables (non-integer numerics rounded to 1 dp for display only;
integer-valued columns left untouched), and a trailing `DeletionCheck`
flag (1 for rows the filter will drop).

## Usage

``` r
.jst_jcomplete_preview(
  masked,
  variable_names,
  show_all = FALSE,
  console = FALSE,
  viewer = TRUE,
  data_name = NULL
)
```

## Arguments

- masked:

  Analysis copy with SPSS-form UDMs masked to NA.

- variable_names:

  Character vector of the registered variables.

- show_all:

  Logical. If `TRUE`, the viewer shows every case; otherwise only the
  rows scheduled for deletion. Does not affect the console output, which
  is always deleted-rows-only.

- console:

  Logical or numeric. `FALSE` (default) prints nothing to the console;
  `TRUE` prints the first 10 deleted rows; a number prints that many.
  Independent of `viewer`.

- viewer:

  Logical. If `TRUE` (and the session is interactive), open the data
  viewer. Independent of `console`.

- data_name:

  Character. The data frame name, used in the viewer title and the
  fallback messages.

## Value

Invisibly, the data frame shown in the viewer.

## Details

The viewer (RStudio data tab) and the console listing are controlled
independently by the caller (`viewer` and `console`); each shows only
what is asked for. The viewer shows either the deleted rows only or all
cases (`show_all`); the console always shows deleted rows only, capped,
so it cannot flood the console. The console listing also serves as the
automatic fallback when the viewer was requested but no interactive
viewer is available.
