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
  cps_toggle = NULL
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

## Value

A list: render, render_top, render_bottom, endpoint_label,
show_auto_listwise, resolved_tier, hide_second_col_pair.
