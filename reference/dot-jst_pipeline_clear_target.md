# Internal helper: resolve which data frame a bare `f(NULL)` clears

The single decision point for the bare-`NULL` form of the two toggleable
pipeline setters, `jsubset(NULL)` and `jcomplete(NULL)`, so the pair
resolves a frame exactly as the registration verbs'
[`.jst_handle_clear()`](https://jma61.github.io/jstats/reference/dot-jst_handle_clear.md)
does (S289 alignment, shipped S294): the
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
frame when one is set; otherwise the sole frame carrying a setting when
exactly one does; otherwise – more than one frame and no default – stop
and ask the user to name a frame or pass `clear.all = TRUE`, never a
silent multi-frame wipe. The caller performs the clear and emits its own
message; this helper only chooses the frame, or stops.

## Usage

``` r
.jst_pipeline_clear_target(fn_label, frames, default_name = NULL)
```

## Arguments

- fn_label:

  Character function label (`"jsubset"` or `"jcomplete"`), used in the
  ambiguity error.

- frames:

  Character vector of the data frame names currently carrying a setting
  of this kind (NULL entries already dropped).

- default_name:

  The [`juse()`](https://jma61.github.io/jstats/reference/juse.md)
  default frame name, or `NULL`.

## Value

The name of the frame to clear, or `NULL` when no frame carries a
setting and no default is set (the caller reports "nothing to clear").
Never returns when the choice is ambiguous.
