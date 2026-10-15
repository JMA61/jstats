# Internal helper: stop for a workspace vector that would be recycled

The message for a
[`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)
finding, shared by the formula front door (Session 324) and a filter
condition typed in this call –
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) at
set time and `subset =` (Session 330). Since ruling R19 (Session 357) an
object of one value per case stops before this is reached
([`.jst_frame_object()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object.md)),
so what is left is a length that is neither one nor one per case. A
workspace object opens as R19's message does – not in the data frame, a
separate object – and gets the requirement "Use a single value, or add
the values to the data frame as a variable."; a vector written in the
call (`c(1, 2, 3)`, `1:5`) keeps "or one value for each case", which a
vector written there may be. A stored filter has its own form, in
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md).

## Usage

``` r
.jst_recycled_stop(
  rec,
  typed,
  n_rows,
  data_name = NULL,
  n_frame = NULL,
  tail = ""
)
```

## Arguments

- rec:

  The
  [`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)
  result.

- typed:

  Character; what the user typed that holds the operand: the computed
  term, the condition, or `subset = ` and the condition.

- n_rows:

  Integer; rows of the data the expression is evaluated on.

- data_name:

  Character or NULL; the data frame's name.

- n_frame:

  Integer or NULL; the frame's row count before the pipeline's filters.
  NULL is read as `n_rows`.

- tail:

  Character; appended after the requirement (the set-time "earlier
  filter is unchanged" line).

## Value

Does not return; stops.
