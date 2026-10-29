# Internal helper: the line a near miss adds for a newer file

When a style file was written by a newer jstats, a name that is close to
a known one may still be a newer setting; the stop says so.

## Usage

``` r
.jst_style_newer_line(newer, file, ver)
```

## Arguments

- newer:

  Logical(1); the file comes from a newer jstats.

- file:

  Character(1); the file's name, as messages give it.

- ver:

  Character(1); the version that wrote the file.

## Value

Character(1) starting with a newline, or NULL.
