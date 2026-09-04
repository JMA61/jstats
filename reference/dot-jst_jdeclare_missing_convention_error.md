# Internal helper: build jdeclare_missing's cross-convention error message

Produces the error message used by
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
when Stata-style missing-value tokens appear in the `codes` argument but
the resolved convention is SPSS. Verbosity is controlled by the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jdeclare_missing_convention_error(
  parsed_codes,
  data_name,
  var_name,
  col,
  per_call_convention = NULL,
  tagged_raw = NULL,
  arg_label = "codes"
)
```

## Arguments

- parsed_codes:

  Named numeric vector. Names are labels (`""` where no label was
  given). Values are the user's codes including any tagged-NA elements.

- data_name:

  Character. Name of the data frame in the user's call (used to
  reconstruct the example).

- var_name:

  Character. Name of the variable being declared.

- col:

  The column being declared. Its own declared codes supply the
  substituted values in the example call.

- per_call_convention:

  Character or `NULL`. The caller's raw per-call `convention` argument.
  It seeds the display convention for the prescriptive positions; it
  plays no part in whether the error fires.

- tagged_raw:

  Named character vector or `NULL`, as recorded by
  [`.jst_parse_code_tokens()`](https://jma61.github.io/jstats/reference/dot-jst_parse_code_tokens.md):
  canonical lowercase marker letter to the spelling the caller typed.
  Seeds the quoted positions. A letter absent from it falls back to the
  display case.

- arg_label:

  Character. Which argument the markers arrived in – `"codes"` normally,
  `"labels"` on the labels-only form. The message names the argument the
  caller actually used.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
