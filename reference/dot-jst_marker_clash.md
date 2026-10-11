# Internal helper: would declaring codes put them on markers a variable has?

jdeclare_missing() converts numeric codes on a variable of Stata or SAS
form to markers from the start of the alphabet, and since v0.9.218 it
refuses a code whose letter the variable already carries, in a cell or
as a labeled value. A message that offers jdeclare_missing(..., codes =
) for such a variable printed a line that stops (ruling R8's offered
declarations, Session 352). This reads the convention the call would
resolve – the variable's own form, else the per-call convention, else
the setting – and says whether the first `n` letters meet a marker the
variable carries.

## Usage

``` r
.jst_marker_clash(col, n, per_call = NULL)
```

## Arguments

- col:

  The variable.

- n:

  The number of codes the declaration would name.

- per_call:

  A per-call convention, or NULL.

## Value

NULL when the declaration would run as offered; otherwise a list:
`conv`, the convention, and `tags`, the markers carried.
