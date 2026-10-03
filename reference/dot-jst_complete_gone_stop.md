# Internal helper: stop for a jcomplete setting naming absent variables

A stored
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
setting can outlive its variables: one dropped or renamed after the
setting was made, or the frame's name reassigned to a frame without it.
This is the one stop for that condition, raised wherever the setting is
about to be used: Step 1 of
[`.jst_apply_pipeline()`](https://jma61.github.io/jstats/reference/dot-jst_apply_pipeline.md)
(every analysis of the frame, since Session 330), and since Session 331
`jcomplete(d, on)` and the preview of an already-set filter
(`jcomplete(preview = TRUE)`, `console =`), which until then reactivated
the setting unchecked and previewed the rows the REMAINING variables
would drop. Does nothing when no variable is absent. At reactivation the
setting is off, and the message says it stays off.

## Usage

``` r
.jst_complete_gone_stop(data_name, gone_vars, reactivate = FALSE)
```

## Arguments

- data_name:

  Character. The data frame's name.

- gone_vars:

  Character vector: the setting's variables the frame no longer has
  (empty: return without stopping).

- reactivate:

  Logical. TRUE from `jcomplete(d, on)`: adds "The setting stays off."
  after the first line.

## Value

`invisible(NULL)` when `gone_vars` is empty; otherwise stops via
[`.jst_stop()`](https://jma61.github.io/jstats/reference/dot-jst_stop.md).
