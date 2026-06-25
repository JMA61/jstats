# Internal helper: format categorical levels under a value.id mode

Shared formatter that maps stored codes (plus their value labels, if
any) to display strings under the active `value.id` mode. Every surface
where categorical levels appear – jfreq valid rows, jt/jaov group
headers, jcrosstab axes, grouped jdesc group headers – routes its
code/label display through this one helper so the modes behave
identically across functions and the per-code degrade logic lives in a
single place.

## Usage

``` r
.jst_format_value_labels(codes, val_labels, mode = "both")
```

## Arguments

- codes:

  Vector of stored values (numeric or character), one per level or per
  row. NA entries (system-missing) map to NA in the output.

- val_labels:

  Named vector as returned by
  [`labelled::val_labels()`](https://larmarange.github.io/labelled/reference/val_labels.html)
  (names are the labels, values are the codes), or NULL / length-0 when
  the variable carries no value labels.

- mode:

  One of `"both"`, `"values"`, `"labels"`, `"legend"`,
  `"legend.bottom"`. The legend modes behave as `"values"` for the
  returned in-table vector.

## Value

Character vector parallel to `codes`.

## Details

Degrades per CODE, not per variable: `"labels"` shows the label where
one exists, otherwise that bare code; `"both"` shows `"code: label"`
where a label exists, otherwise the bare code (so a variable with no
value labels at all collapses to bare codes – the emergent
whole-variable behaviour). `"values"` always shows the bare stored code.
The two legend modes (`"legend"`, `"legend.bottom"`) render bare codes
in-table exactly like `"values"` – the code-\>label mapping is emitted
separately as a legend block by the calling function (see
`.print_value_labels`). Plain numeric (unlabelled) variables therefore
render identically under every mode, so value.id is a no-op for them.

In-table content is capped to a display-width ceiling via
`.jst_truncate_ellipsis` (shared 40-column cap). This bites only under
`"both"`/`"labels"` where a long value label would otherwise widen the
category column for every row; bare codes are short and unaffected. The
cap is applied here, in the formatting layer, so the (already-capped)
string is what reaches `.jst_print_table` – the printer stays
width-agnostic.

Works for both numeric-backed and character-backed haven_labelled
variables: codes are compared as character on both sides, so string
codes (e.g. "US"/"UK") are never coerced to numeric.
