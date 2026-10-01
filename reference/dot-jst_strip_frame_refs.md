# Internal helper: rewrite frame\$column references as bare variable names

Builds the corrected form for the data-frame refusals. Each
`frame$column`, or `frame[["column"]]` with a quoted name, on a frame in
`frames` becomes the bare name `column`; nothing else moves. `clean` is
TRUE when at least one reference was rewritten and no other reference to
those frames remains – `d[, 2]` or `nrow(d)` cannot be rewritten as a
variable name – so a caller prints a fix line only when the rewrite is
complete. `summary` is TRUE when a reference sits inside a summary
function (`mean(d$Income)`): that is a value computed from the frame,
not a variable, and rewritten it would be computed on the analysis copy,
where declared missing values are NA, so the caller gives the
save-it-first form instead. (Session 323.)

## Usage

``` r
.jst_strip_frame_refs(e, frames)
```

## Arguments

- e:

  A language object (a formula, a term, or a condition).

- frames:

  Character vector of data frame names.

## Value

A list of `expr` (the rewritten expression), `cols` (the variable names
now used in place of the references, unique), `clean` (logical) and
`summary` (logical).
