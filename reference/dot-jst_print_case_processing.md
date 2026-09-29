# Internal helper: print the Case Processing Summary (CPS)

Resolves a render spec from the .jst_cps\_\*\_rules tables (via
`.jst_resolve_cps_render`) and draws, in the block's slot at the top of
the output, EITHER the top table (pipeline chain) OR the one-line N
statement (S284 rule 3), and beneath whichever printed, where the spec
calls for it, the bottom table (per-variable missing-data breakdown,
totals or per_code tier, with the jcomplete()-only variables' rows after
the analysis variables' – Session 312). Contains no render-rule logic of
its own; all show/hide decisions and the N line's form arrive
pre-resolved.

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

  Layout key: `"listwise"`, `"pairwise"`, `"per_var_desc"`,
  `"per_var_freq"`, or `"screening"` (Session 320, jscreen).

- detail:

  Per-call case.processing.detail override (NULL, "none", "totals",
  "per_code"). NULL defers to the joutput tier default.

- notification_template, data, analysis_vars:

  Listwise-discrepancy notification inputs (per-variable layouts only);
  see the closure below.

## Value

Invisibly, a list: `mode`, `render_top`, `render_n_line`, `n_line_form`,
and `header_excluded` – the count a header-family caller (jscreen)
appends to its own Cases line as "(k Excluded)", nonzero only when the
block fell to the N-line state after cases were excluded (Session 320;
`invisible(NULL)` until then). The empty-frame branch still returns
`invisible(NULL)`.

## Details

Display design = JStats_CPS_Rendering_Reference.txt (four layouts, Form
B bottom). Missing-value semantics =
JStats_Missing_Values_Reference.txt.
