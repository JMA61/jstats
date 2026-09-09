# Internal helper: resolve the CPS render spec from the rule tables

Reads the three .jst_cps\_\*\_rules frames and applies layer precedence
(Visibility first; if not rendered, returns early). Contains no rules of
its own. Errors loudly on a coordinate that matches no row.

## Usage

``` r
.jst_resolve_cps_render(
  layout,
  pipeline_active,
  has_udms,
  has_sysna,
  output_level,
  detail_tier,
  cps_toggle = NULL,
  has_transform_na = FALSE,
  n_excluded_missing = 0L,
  unequal_ns = FALSE
)
```

## Arguments

- layout:

  One of `"listwise"`, `"pairwise"`, `"per_var_desc"`, `"per_var_freq"`.

- pipeline_active:

  Logical. Any of jcomplete/jsubset/subset fired.

- has_udms:

  Logical. At least one analysis variable has a declared UDM.

- has_sysna:

  Logical. At least one analysis variable has plain-NA missingness (in
  source or pool).

- output_level:

  One of `"minimal"`, `"standard"`, `"full"`.

- detail_tier:

  One of `"none"`, `"totals"`, `"per_code"`.

- cps_toggle:

  Resolved case.processing toggle: `TRUE` (always), `FALSE` (never), or
  `NULL` (auto -\> use output_level).

- has_transform_na:

  Logical. At least one resolved formula-transform term produced
  non-finite values that the resolver converted to NA
  (transform-introduced missingness; the per-term counts travel in
  sample_info\$transform_na). Folded into the bottom lookup's has_sysna
  coordinate – by the time the model sees them these cells are ordinary
  case-level NAs, just introduced by a computed term rather than present
  in a source column – so the bottom frame gains an INPUT but no new
  rows (AUDIT-025). Since S284 it no longer reaches the visibility gate:
  a transform-driven exclusion shows up in n_excluded_missing, which is
  what the gate now reads.

- n_excluded_missing:

  Integer. Cases the analysis dropped listwise after the pipeline
  (sample_info\$n_excluded_missing). Decides whether an eligible
  Auto-listwise row is shown (nonzero only, S284 rule 2), and through it
  whether the upper table has an exclusion row.

- unequal_ns:

  Logical. Pool family only: the analysis variables' per-variable Ns
  differ, so the N line adds the complete-on-all count.

## Value

A list: mode, render_top, render_n_line, render_bottom, endpoint_label,
show_auto_listwise, resolved_tier, hide_second_col_pair, n_line_form.
