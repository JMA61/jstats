# Internal helper: stop for a workspace vector that would be recycled

The message for a
[`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)
finding, shared by the formula front door (Session 324) and a filter
condition typed in this call –
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) at
set time and `subset =` (Session 330). A vector with one value per row
of the frame as given, which a filter has since cut down, gets the fix
of adding it to the frame, where the filter reaches it; any other length
gets the requirement. A stored filter has its own form, in
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md).

## Usage

``` r
.jst_recycled_stop(
  rec,
  typed,
  n_rows,
  data_name = NULL,
  n_frame = NULL,
  tail = "",
  cut_by = "filtering"
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

  Character; appended after the fix line (the set-time "earlier filter
  is unchanged" line).

- cut_by:

  Character; what cut the frame, for the add-it-to-the-frame form:
  `"filtering"` (a per-call condition behind the stored settings) or
  `"jcomplete()"` (a
  [`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
  filter behind an active
  [`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md),
  Session 331).

## Value

Does not return; stops.
