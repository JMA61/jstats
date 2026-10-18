# Internal: jdeclare_missing() on text variables

The route a call naming text variables takes (Slate E5; rulings R26 and
R27; see the banner above). Called by
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
once the data frame and the variables are resolved, with the call's
arguments as given; returns the data frame. Every line it offers names
the data frame and the text variables, keeps codes and labels as typed
(numbers quoted), and leaves out what a text variable cannot take
(`convention = "stata"` or `"sas"`, `range`), so a line never stops on a
second problem (ruling R23).

## Usage

``` r
.jst_jdeclare_missing_text(
  data,
  data_name,
  data_kind,
  data_sub_expr,
  arg1,
  target_vars,
  codes,
  labels,
  range,
  convention,
  missing.notice,
  modify,
  cl,
  mc,
  vars,
  vars_sub_expr,
  envir,
  bare = NULL
)
```
