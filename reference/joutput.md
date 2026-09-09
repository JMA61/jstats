# Set session-level output verbosity

Controls what analysis functions display by default. Three preset levels
are available, and individual toggles can override specific settings
within any level. Per-call arguments on analysis functions always take
precedence over joutput() settings.

## Usage

``` r
joutput(
  level,
  effect.size = NULL,
  regression.ci = NULL,
  means.ci = NULL,
  levene = NULL,
  posthoc = NULL,
  diagnostics = NULL,
  case.processing = NULL,
  case.processing.detail = NULL,
  variable.id = NULL,
  value.id = NULL,
  ref.categories = NULL,
  missing.notice = NULL,
  digits = NULL,
  quiet = FALSE
)
```

## Arguments

- level:

  Character. One of `minimal`, `standard` (default), or `full`. If
  omitted, prints the current settings. If `NULL`, resets to defaults
  (standard with no toggle overrides).

  minimal

  :   Stripped-down output for power users. Core results only – no Case
      Processing table (a one-line N statement in its place), no
      variable labels, no reference categories, no effect sizes, no CIs.

  standard

  :   Default. Suitable for teaching and routine use. Includes the Case
      Processing table when a filter or listwise deletion excluded cases
      (otherwise a one-line N statement), reference categories, effect
      sizes, and confidence intervals for means and mean differences
      (`jt`, `jaov`); regression coefficient CIs (`jlm`, `jlogistic`)
      are reserved for full. Variable labels are off by default
      (`variable.id = "names"`); request a label legend or in-table
      labels per call or via the `variable.id` toggle.

  full

  :   Everything in standard plus a variable label legend
      (`variable.id = "legend"`), regression coefficient confidence
      intervals, assumption checks (Levene's test), post-hoc tests,
      regression diagnostics, and the Case Processing table on every
      call, with the per-code missing breakdown.

- effect.size:

  Logical or NULL. Override the level's default for effect size display.

- regression.ci:

  Logical or NULL. Override the level's default for confidence intervals
  on regression coefficients (`jlm`, `jlogistic`). Off at minimal and
  standard, on at full.

- means.ci:

  Logical or NULL. Override the level's default for confidence intervals
  on means and mean differences (`jt`, `jaov`). Off at minimal, on at
  standard and full.

- levene:

  Logical or NULL. Override the level's default for Levene's test
  display.

- posthoc:

  Logical or NULL. Override the level's default for post-hoc test
  display (jaov only).

- diagnostics:

  Logical or NULL. Override the level's default for regression
  diagnostic output (jlm only).

- case.processing:

  Three-state toggle for the Case Processing table – the block at the
  top of every analysis function's output that accounts for the cases:
  the original N, each active filter (`jcomplete`, `jsubset`, per-call
  `subset`) with the cases it excluded, any cases dropped listwise by
  the analysis, and the N analyzed.

  Every call states its N. What the toggle decides is the FORM: when the
  table does not print, a one-line N statement takes its place
  (`Analysis N: 63` for the listwise functions; for `jdesc`, `jfreq`,
  and `jcorr`, the number of cases in the variable pool, adding the
  count complete on every variable when the per-variable Ns differ, and
  adding the excluded count whenever cases were excluded before the
  analysis).

  - `NULL` (auto; the standard tier's default) prints the table only
    when it has an exclusion row to show: a filter is active (shown even
    when it excluded 0 cases, as the reminder that it is active) or
    listwise deletion dropped at least one case. Otherwise the N
    statement. A clean call with no filter therefore gets one line, not
    a table of zeros.

  - `TRUE` (the full tier's default) prints the table on every call,
    even when its only rows are Original and the final N.

  - `FALSE` (the minimal tier's default) never prints the table or its
    missing-data breakdown; the N statement only.

  In every form, a listwise-deletion row appears only when it dropped at
  least one case; a clean analysis never shows a `Auto-listwise 0` row.
  The missing-data breakdown beneath the table (or beneath the N
  statement) is governed separately by `case.processing.detail`.

- case.processing.detail:

  Detail tier for the Case Processing Summary's missing-data breakdown:
  `"none"` (no bottom table), `"totals"` (one summed missing row per
  variable), or `"per_code"` (per declared missing-value code plus
  system-missing). The minimal tier defaults to `"none"`, standard to
  `"totals"`, full to `"per_code"`.

- variable.id:

  Character or NULL. Variable label display mode, one of `"both"`,
  `"names"`, `"labels"`, `"legend"`, or `"legend.bottom"`. `"names"`
  shows variable names only; `"both"` shows `"name: label"`, with no
  labels block. `"labels"` replaces variable names with their labels in
  the analysis output itself (table rows, captions, crosstab dimnames,
  or `jplot` axis/legend titles) – best when labels are short.
  `"legend"` keeps names in place and prints a label legend at the
  function's mid position (for `jlm`/`jlogistic` between the
  coefficients and fit blocks; for `jfreq` under each variable's own
  table; elsewhere directly after the single table). `"legend.bottom"`
  keeps names in place and prints one consolidated legend at the very
  end of the output. The minimal and standard tiers default to
  `"names"`; the full tier defaults to `"legend"`. Not a logical –
  `TRUE`/`FALSE` are not accepted.

- value.id:

  Character or NULL. Value-label display mode for the categorical levels
  that appear in `jfreq` valid rows, the `jt`/`jaov` group descriptives,
  the `jcrosstab` axes, and the grouped `jdesc` headers. One of `"both"`
  (`"code: label"`, degrading to a bare code where a code has no label),
  `"values"` (the bare stored code), or `"labels"` (the value label,
  degrading to the bare code per code where none exists). `"legend"` and
  `"legend.bottom"` keep the bare code in the table and print a
  value-label legend after it (`"legend"` per-table, `"legend.bottom"`
  consolidated where multiple tables are produced). Variables with no
  value labels render identically under all three modes, so this is a
  no-op for plain numeric data. The minimal tier defaults to `"values"`;
  the standard and full tiers default to `"both"`. Distinct from
  `variable.id`, which governs the one-per-variable descriptive label.
  Not a logical.

- ref.categories:

  Logical or NULL. Override the level's default for the reference
  categories block (registered dummies).

- missing.notice:

  Logical or NULL. Controls the notification about declared missing
  values that
  [`jload()`](https://jma61.github.io/jstats/reference/jload.md) emits
  for files whose variables carry them. `TRUE` prints it on every such
  load; `FALSE` suppresses it; `NULL` (the default) leaves the level's
  setting in place. The standard and full levels print it; the minimal
  level suppresses it.

- digits:

  Integer or NULL. Number of decimal places shown for continuous
  statistics in the analysis-function output tables (range 0-7;
  `digits = 0` prints whole numbers with no trailing decimal point).
  Does not affect p-values, percentages, or integer quantities (counts,
  N, degrees of freedom), which keep their own fixed conventions. All
  three preset levels default to 3.

- quiet:

  Logical; default FALSE. When TRUE, joutput() applies the level/toggle
  change silently (the status panel is not printed). A bare joutput()
  status query always prints regardless of quiet.

## Value

Invisibly returns NULL. Called for its side effect of setting session
options.

## Session options

`joutput()` stores its settings through R's standard
[`options()`](https://rdrr.io/r/base/options.html) /
[`getOption()`](https://rdrr.io/r/base/options.html) mechanism, under
two keys: `.jst_output_level` (the preset level) and
`.jst_output_toggles` (a named list holding any per-slot overrides).
`getOption(".jst_output_level")` returns the raw stored level – `NULL`
until a level has been set, which the package reads as the `"standard"`
default. `joutput(NULL)` clears both keys. The same values can be read
or set with base R's [`options()`](https://rdrr.io/r/base/options.html)
directly; `joutput()` is the supported interface, adding validation and
the settings display.

## See also

[`jstats`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview, workflow conventions, and complete function
listing.

## Examples

``` r
joutput("standard")                       # effect sizes + means/diff CIs (jt, jaov)
#> Output Settings
#> Level: standard
#>   effect.size: ON
#>   regression.ci: OFF
#>   means.ci: ON
#>   levene: OFF
#>   posthoc: OFF
#>   diagnostics: OFF
#>   case.processing: AUTO
#>   case.processing.detail: TOTALS
#>   variable.id: NAMES
#>   value.id: BOTH
#>   ref.categories: ON
#>   missing.notice: ON
#>   digits: 3
#> 
joutput("standard", regression.ci = TRUE) # also show jlm/jlogistic coefficient CIs
#> Output Settings
#> Level: standard
#>   effect.size: ON
#>   regression.ci: ON (override)
#>   means.ci: ON
#>   levene: OFF
#>   posthoc: OFF
#>   diagnostics: OFF
#>   case.processing: AUTO
#>   case.processing.detail: TOTALS
#>   variable.id: NAMES
#>   value.id: BOTH
#>   ref.categories: ON
#>   missing.notice: ON
#>   digits: 3
#> 
joutput("full")                         # everything
#> Output Settings
#> Level: full
#>   effect.size: ON
#>   regression.ci: ON
#>   means.ci: ON
#>   levene: ON
#>   posthoc: ON
#>   diagnostics: ON
#>   case.processing: ON
#>   case.processing.detail: PER_CODE
#>   variable.id: LEGEND
#>   value.id: BOTH
#>   ref.categories: ON
#>   missing.notice: ON
#>   digits: 3
#> 
joutput()                               # show current settings
#> Output Settings
#> Level: full
#>   effect.size: ON
#>   regression.ci: ON
#>   means.ci: ON
#>   levene: ON
#>   posthoc: ON
#>   diagnostics: ON
#>   case.processing: ON
#>   case.processing.detail: PER_CODE
#>   variable.id: LEGEND
#>   value.id: BOTH
#>   ref.categories: ON
#>   missing.notice: ON
#>   digits: 3
#> 
getOption(".jst_output_level")          # the raw option behind the level
#> [1] "full"
joutput(NULL)                           # reset to defaults
#> Output Settings
#> Reset to defaults (standard, no toggle overrides).
#> 
```
