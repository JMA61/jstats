# Internal helper: where jstyle(save.as =) writes

A name with a folder is written where it says (the folder must exist); a
bare name goes in the style folder when one is set, else in the per-user
folder, which is created here, by the user's own call (CRAN's rule: a
package writes there only when asked). The .jstyle extension is added
when the name has none; "apa" is the built-in style's name.

## Usage

``` r
.jst_style_save_path(save.as)
```

## Arguments

- save.as:

  The name given.

## Value

The path to write.
