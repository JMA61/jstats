# Internal helper: handle the formula-first form of jplot

Called by `jplot.default` when the first argument is a formula. Parses
the formula into DV (y-axis) and IV (x-axis), resolves the data frame
from the second positional argument or juse default, and dispatches to
the scatter or box builder depending on the IV's type.

## Usage

``` r
.jst_jplot_formula(
  formula,
  jplot_call,
  ...,
  by_expr,
  type,
  line,
  equation,
  r2,
  band,
  subset_expr,
  labels,
  numeric = NULL,
  categorical = NULL,
  count = NULL,
  parent_env
)
```

## Details

Only single-IV formulas are supported (`DV ~ IV`). Multi-IV formulas
produce a helpful error pointing to the jlm() + jplot(m) workflow.
