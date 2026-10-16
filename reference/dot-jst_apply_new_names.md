# Internal: rename a frame's variables, keeping each old name as a label

A renamed variable with no label of its own is given its old name as its
variable label (the header kept, ruling R9); one with a label keeps it,
and the old name is in the note only. An empty old name gives no label.

## Usage

``` r
.jst_apply_new_names(df, new, changed)
```

## Arguments

- df:

  A data frame.

- new:

  The new names, one per variable.

- changed:

  Logical: which changed.

## Value

list(df, had): the renamed frame, and for each changed variable "own"
(it had a label of its own), "given" (its old name is its label) or
"none" (its old name was empty).
