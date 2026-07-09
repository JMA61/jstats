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
  udm.notice = NULL,
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
      Processing Summary, no variable labels, no reference categories,
      no effect sizes, no CIs.

  standard

  :   Default. Suitable for teaching and routine use. Includes Case
      Processing Summary, reference categories, effect sizes, and
      confidence intervals for means and mean differences (`jt`,
      `jaov`); regression coefficient CIs (`jlm`, `jlogistic`) are
      reserved for full. Variable labels are off by default
      (`variable.id = "names"`); request a label legend or in-table
      labels per call or via the `variable.id` toggle.

  full

  :   Everything in standard plus a variable label legend
      (`variable.id = "legend"`), regression coefficient confidence
      intervals, assumption checks (Levene's test), post-hoc tests,
      regression diagnostics, and the most detailed Case Processing
      Summary (per-code missing breakdown).

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

  Three-state toggle. `TRUE` forces the Case Processing Summary to print
  on every call. `FALSE` suppresses it on every call. `NULL` (the
  auto-suppress default at the standard tier) prints only when the call
  had something to report – pipeline state was active (`jsubset`,
  `jcomplete`, or per-call `subset`), listwise deletion excluded at
  least one case (in listwise functions like `jlm`, `jt`), or a
  per-variable discrepancy notification fires (in `jdesc`/`jfreq`). The
  minimal tier sets this to `FALSE`; the full tier sets it to `TRUE`;
  the standard tier sets it to `NULL`.

- case.processing.detail:

  Detail tier for the Case Processing Summary's missing-data breakdown:
  `"none"` (no bottom table), `"totals"` (one summed missing row per
  variable), or `"per_code"` (per user-defined missing value code plus
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
  end of the output. The minimal and standard tiers default to `"none"`;
  the full tier defaults to `"legend"`. Not a logical – `TRUE`/`FALSE`
  are not accepted.

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

- udm.notice:

  Logical or NULL. Controls the user-defined missing-value (UDM)
  notification emitted by
  [`jload()`](https://jma61.github.io/jstats/reference/jload.md) for
  files with UDM-bearing variables. `TRUE` prints it on every such load;
  `FALSE` suppresses it; `NULL` (the default) leaves the level's setting
  in place. The standard and full levels print it; the minimal level
  suppresses it.

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
#>   udm.notice: ON
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
#>   udm.notice: ON
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
#>   udm.notice: ON
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
#>   udm.notice: ON
#>   digits: 3
#> 
joutput(NULL)                           # reset to defaults
#> Output Settings
#> Reset to defaults (standard, no toggle overrides).
#> 
```
