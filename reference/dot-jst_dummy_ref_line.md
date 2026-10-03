# Internal helper: the "Reference category:" line of a dummy registration

One builder for the line the three displays of a registration print – on
registration, when an existing registration is shown again, and in the
no-argument overview – so they cannot drift. When the reference was
chosen by the default rule (`ref = "auto"`, typed or not), the line
closes with `(default; change with ref =)`: the bare line read as if the
starred category were the only one possible, and a reader coming from
software whose default is the LAST category could take the wrong one for
granted (Session 329, Jeff). A reference the user named carries no tag.
The registration's `ref_default` field records which; a registration
made before the field existed (restored from an older .rds file) has
none and prints without the tag, since how its reference was chosen is
not known.

## Usage

``` r
.jst_dummy_ref_line(reg, with.code = FALSE)
```

## Arguments

- reg:

  A registration object (uses `ref_label`, `ref_code` and
  `ref_default`).

- with.code:

  Logical. If TRUE the label is preceded by its code
  (`1: Condition_Control`), the form the overview prints.

## Value

A character string ending in a newline, for
[`cat()`](https://rdrr.io/r/base/cat.html).
