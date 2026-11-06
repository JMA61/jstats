# Internal helper: a style file's blank lines

One blank line after each setting, and none between a setting's notes
and the setting (Session 410, the (S409) item; Jeff, on build 1's walk:
"I think it will read better if there was a blank line after each of the
actual settings (but not between the comments and the setting)."): the
writers put a blank line after every setting and before every part, and
this keeps one where two meet and none at the end of the file. The
reader skips blank lines wherever they are.

## Usage

``` r
.jst_style_blank_lines(out)
```

## Arguments

- out:

  Character, the file's lines.

## Value

Character, the lines with no blank line repeated or last.
