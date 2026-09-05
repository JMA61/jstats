# Internal: format the UDM narrative notification text

Builds the message string emitted when UDM-bearing variables are
detected during a load. The S227 (E17) redesign conditions the text on
three things: the convention(s) actually read (per-variable `convention`
from
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)),
the `missing.convention` setting in
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md), and
whether the full form has already been shown this session (`compact`).

## Usage

``` r
.jst_format_udm_narrative(
  udm_info,
  preserve.declarations,
  max_show = 10L,
  data_name = "data",
  compact = FALSE
)
```

## Arguments

- compact:

  Logical. `TRUE` selects the repeat-showing compact form described
  above.

## Details

Shapes produced under `preserve.declarations = TRUE`:

- Uniform frame: style-named header ("5 variables have SPSS-style
  missing values:"). SPSS-style frames with no conflicting setting add
  the base-R gap fact and the one jconvert remedy; Stata- and SAS-style
  frames add nothing, since tagged markers are already NA to base R.

- Uniform frame under an explicitly set, different `missing.convention`:
  a setting-mismatch note with two equal-standing remedies (change the
  setting, or convert the data), neither recommended – the Rule D
  equal-standing-remedies carve-out (S227).

- Mixed frame: grouped-count header ("6 variables have missing values (5
  SPSS-style, 1 Stata-style):") plus a mixes note with one align line
  per real style present. Under an explicitly set convention the note
  instead names the off-setting columns, the setting's own style leads
  the align lines, and align targets other than the setting carry a
  joptions rider so the setting is not left stale. Ambiguous mixed-case
  tagged columns (convention NA, Decision 13) form their own
  "mixed-case" display group and get no align line of their own – any
  align target collapses them.

- Compact form (second and later showings in a session, unless the call
  passed `missing.notice = TRUE`): header + inventory, with the
  convention note retained – it is frame-specific, and compaction must
  not silence a new frame's mismatch – and the Case 1 guidance lines
  dropped.

The setting-MISMATCH notice is gated on an explicitly set
`missing.convention`: a user who stated no preference must never be
nagged about a mismatch with it (S226). Mixed-frame ALIGN lines are not
so gated – each carries a `joptions(missing.convention = ...)` rider
whenever running it would leave the setting not matching the result,
which under `"none"` means both of them (S227; the joptions rider rule
in the missing-values reference). The rider is not a suggestion to adopt
a convention – it is the second half of a remedy the user has already
chosen to run.

The `preserve.declarations = FALSE` branch (declarations converted to
plain NA on request) keeps its original shape with a style-named header
and is never compacted – it reports a destructive action the user
explicitly requested.

Renders SPSS UDM codes (e.g. `-99`) and tagged markers (e.g. `.a`) using
parallel notation: `code ["label"]` or `code (no label)`. The code form
comes pre-rendered in the `code` column of
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)'s
return.
