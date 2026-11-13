# Internal helper: keep a call's output on its result

Sets the attribute `jstats_output` – the parts the scope kept, a
character vector named "out" (standard output) and "message" (a note) in
the order they were written – on a result of one of the ten analysis
classes (Session 423). Any other value passes untouched: jscreen()'s
data frame, which prints as a table.

## Usage

``` r
.jst_scope_result(x, ctx = NULL)
```

## Arguments

- x:

  The value.

- ctx:

  A scope's context, or NULL for the innermost scope open (a body that
  returns early).

## Value

`x`, the attribute set where it applies.
