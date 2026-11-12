# Internal helper: does a text file read as a style file?

Every line that is not blank or a note is a section's heading or a name,
an equals sign and a value, and at least one name is a setting jstats
has or one of a file's own three lines. A file that cannot be read as
text is not one.

## Usage

``` r
.jst_style_text_like(path)
```

## Arguments

- path:

  The file.

## Value

Logical(1).
