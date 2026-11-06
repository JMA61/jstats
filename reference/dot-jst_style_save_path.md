# Internal helper: where jstyle(save.as =) writes

A name with a folder is written where it says (the folder must exist); a
bare name goes in the style folder when one is set, else in the per-user
folder, which is created here, by the user's own call (CRAN's rule: a
package writes there only when asked). The .jstyle extension is added
when the name has none; "apa" and "report" are the built-in styles'
names (Session 409), and a name in `.jst_style_reserved` would be a
built-in's still to come (Session 407).

## Usage

``` r
.jst_style_save_path(save.as, from = "apa")
```

## Arguments

- save.as:

  The name given.

- from:

  Character(1); the name of the style the call copies, for the line a
  refused name offers (Session 409: the call's own style, where it was
  always apa).

## Value

The path to write.
