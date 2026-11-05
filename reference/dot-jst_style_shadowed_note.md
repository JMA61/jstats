# Internal helper: the note for style files named like a built-in style

Said where such a file is passed over: when a call names the built-in
(or takes it as the session's style), and under
[`jstyle()`](https://jma61.github.io/jstats/reference/jstyle.md)'s list
of styles (Session 407, the (S406) item's lean, Jeff's default).

## Usage

``` r
.jst_style_shadowed_note(name, paths)
```

## Arguments

- name:

  Character(1); the built-in style's name.

- paths:

  Character; the files, from
  [`.jst_style_shadowed()`](https://jma61.github.io/jstats/reference/dot-jst_style_shadowed.md).

## Value

Character(1), the note, or NULL when there are no files.
