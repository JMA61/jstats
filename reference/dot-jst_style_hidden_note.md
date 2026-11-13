# Internal helper: the note under a copy saved in the hidden folder

The (S420) item, built Session 423: the per-user folder is hidden by
File Explorer on Windows (AppData) and by Finder on a Mac (Library). The
way to open it is the guides' page 6, Keeping your styles, with the
folder's own path: the "Style written to" line gives the file's, which
File Explorer's address bar opens as a file rather than showing its
folder. The folder the last line sets is the one the guides recommend,
Documents/jstats styles, by its full path (the (S423) path item, built
Session 424; Jeff: "Some of my students, even at the masters level, have
a difficult time with the ~ and the concept of a working directory."),
so the line runs as printed and says where the folder is.

## Usage

``` r
.jst_style_hidden_note(dir, visible = .jst_style_visible_dir())
```

## Arguments

- dir:

  The folder's path, as printed.

- visible:

  The folder the last line sets
  ([`.jst_style_visible_dir()`](https://jma61.github.io/jstats/reference/dot-jst_style_visible_dir.md)).

## Value

Character(1).
