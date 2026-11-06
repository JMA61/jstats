# Internal helper: hand a style file to the editor, when open = TRUE asks

Only in an interactive session, with
[`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html), which in
RStudio opens a tab in the editor pane (a script, a rendered page or a
check opens nothing). The session test and the opener are arguments so a
battery can stand in for both.

## Usage

``` r
.jst_style_open(path, open, ask = interactive(), edit = utils::file.edit)
```

## Arguments

- path:

  The file.

- open:

  Logical.

- ask:

  Logical; whether the session is interactive.

- edit:

  The function that opens the file.

## Value

TRUE when the file was handed to the editor, invisibly.
