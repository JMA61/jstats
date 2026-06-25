# Internal helper: print the Case Processing Summary (CPS)

Resolves a render spec from the .jst_cps\_\*\_rules tables (via
`.jst_resolve_cps_render`) and draws the top table (pipeline chain) and,
where the spec calls for it, the bottom table (per-variable missing-data
breakdown, totals or per_code tier). Contains no render-rule logic of
its own; all show/hide decisions arrive pre-resolved.

## Usage

``` r
.jst_print_case_processing(
  sample_info,
  analysis_type = "listwise",
  detail = NULL,
  notification_template = NULL,
  data = NULL,
  analysis_vars = NULL
)
```

## Arguments

- sample_info:

  List from `.jst_build_sample_info` (carries the pipeline counts plus
  pre_pipeline_data / surviving_ids / analysis_vars).

- analysis_type:

  Layout key: `"listwise"`, `"pairwise"`, `"per_var_desc"`, or
  `"per_var_freq"`.

- detail:

  Per-call case.processing.detail override (NULL, "none", "totals",
  "per_code"). NULL defers to the joutput tier default.

- notification_template, data, analysis_vars:

  Listwise-discrepancy notification inputs (per-variable layouts only);
  see the closure below.

## Value

`invisible(NULL)`.

## Details

Display design = JStats_CPS_Rendering_Reference.txt (four layouts, Form
B bottom). Missing-value semantics =
JStats_Missing_Values_Reference.txt.
