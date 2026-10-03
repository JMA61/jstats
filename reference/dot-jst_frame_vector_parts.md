# Internal helper: the two halves of the add-it-to-the-frame message

One builder for what is said about a workspace vector that holds one
value per case of the frame as given, where the condition runs on fewer
cases: the reason ("keep12 has 12 values, one for each case in the d
data frame, but jcomplete() leaves 11") and the fix ("Add keep12 to the
d data frame as a variable:" and the assignment, when the operand is a
plain name and the frame's name can be typed). Shared by
[`.jst_recycled_stop()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_stop.md)
(a condition typed in this call) and the stored-filter forms in
[`.jst_filter_mask()`](https://jma61.github.io/jstats/reference/dot-jst_filter_mask.md),
so they cannot drift.

## Usage

``` r
.jst_frame_vector_parts(rec, n_rows, data_name = NULL, cut_by = "filtering")
```

## Arguments

- rec:

  A
  [`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)-shaped
  list.

- n_rows:

  Integer; the cases the condition runs on.

- data_name:

  Character or NULL; the data frame's name.

- cut_by:

  Character; what cut the frame.

## Value

A list of two strings, `reason` (no closing period) and `fix`.
