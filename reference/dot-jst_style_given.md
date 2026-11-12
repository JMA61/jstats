# Internal helper: the settings given to jstyle(save.as =), checked

Each general setting, and each setting in a section's list, checked as a
file's value is; a general setting may be given in a section's list, as
a file may set one in a section. A color is kept as it was typed (a name
reads as itself in the file), every other value as the file writes it.

## Usage

``` r
.jst_style_given(given, cl = NULL)
```

## Arguments

- given:

  Named quosures: general settings and section lists.

- cl:

  The call as typed, for the line a stop offers; NULL for none.

## Value

A named list of parts (general first, then the sections in the file's
order), each a named list of the values' text.

## Details

A setting jstats has, given in a list that cannot take it – paper in a
table type's, a general setting in plot's, one section's setting in
another's – stops as a style file's line does
([`.jst_style_misplaced()`](https://jma61.github.io/jstats/reference/dot-jst_style_misplaced.md);
Session 419), with the call rewritten where the setting only has to move
out of its list.
