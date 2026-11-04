# Internal helper: the settings given to jstyle(save.as =), checked

Each general setting, and each setting in a section's list, checked as a
file's value is; a general setting may be given in a section's list, as
a file may set one in a section. A color is kept as it was typed (a name
reads as itself in the file), every other value as the file writes it.

## Usage

``` r
.jst_style_given(given)
```

## Arguments

- given:

  Named quosures: general settings and section lists.

## Value

A named list of parts (general first, then the sections in the file's
order), each a named list of the values' text.
