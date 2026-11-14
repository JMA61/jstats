# Internal helper: the lines jstyle()'s list ends on with no style folder

The (S427) item, built Session 427 in Jeff's wording ("Option 2"): with
no style folder set, a copy jstyle(save.as =) saves goes into the hidden
jstats folder, so the list of styles ends on the line that sets a folder
in Documents, the one the note under such a copy gives
([`.jst_style_hidden_note()`](https://jma61.github.io/jstats/reference/dot-jst_style_hidden_note.md))
– the line the guides' Keeping your styles page sends readers to, shown
without a copy being saved.

## Usage

``` r
.jst_style_unset_text(visible = .jst_style_visible_dir())
```

## Arguments

- visible:

  The folder the last line sets
  ([`.jst_style_visible_dir()`](https://jma61.github.io/jstats/reference/dot-jst_style_visible_dir.md)).

## Value

Character(1), two sentences and the line, newline-separated.
