# Internal helper: open a style's file, for jstyle(open = TRUE)

The style named – or the session's, `joptions(style = )`, when none is –
found as jstyle() finds it and handed to the editor, then checked: a
file holding a value jstats cannot use stops on that line with the file
already open, so it can be put right (Session 409). A built-in style has
no file, and the stop gives the line that saves a copy and opens it. The
session test and the opener are arguments, so a battery can stand in for
both and open nothing, as for jtable()'s `open =`.

## Usage

``` r
.jst_style_open_file(
  style,
  cl = NULL,
  mc = NULL,
  ask = interactive(),
  edit = utils::file.edit
)
```

## Arguments

- style:

  The style argument as given.

- cl, mc:

  The call, for the line a near miss offers.

- ask:

  Logical; whether the session is interactive.

- edit:

  The function that opens the file.

## Value

The style, resolved.
